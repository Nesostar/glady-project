const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

// 👇 1. Callable function to initiate payment
exports.initiateClickPesaPayment = functions.https.onCall(async (data) => {
  const { amount, method, customer_phone, reference } = data;

  const url = 'https://api.clickpesa.com/third-parties/payments/initiate-ussd-push-request';

  const auth = Buffer.from(`IDT1XwUSRhM36MUIlYOtgsFbTxPdEgZl:SKXE1m9g6JNBHKnInMd1FWoGiMnGD6xK6YjN1ccYNE`).toString('base64');

  try {
    const resp = await axios.post(url, {
      amount,
      currency: "TZS",
      payment_method: method,  // e.g. "MPESA" or "TIGOPESA"
      customer_phone,
      reference,
      callback_url: "https://us-central1-church-app-fd5cb.cloudfunctions.net/clickPesaCallback"
    }, {
      headers: {
        Authorization: `Basic ${auth}`,
        'Content-Type': 'application/json'
      }
    });

    const payment = resp.data;
    await admin.firestore().collection('payments').doc(reference).set({
      amount,
      method,
      customer_phone,
      status: 'PENDING',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return { success: true, payment };

  } catch (error) {
    console.error("ClickPesa Error:", error.response?.data || error.message);
    return { success: false, error: error.response?.data || error.message };
  }
});

// 👇 2. HTTP function to receive callback from ClickPesa
exports.clickPesaCallback = functions.https.onRequest(async (req, res) => {
  const { reference, status, transaction_id } = req.body;

  try {
    await admin.firestore().collection('payments').doc(reference).update({
      status,
      transaction_id,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    res.status(200).send('Callback processed');
  } catch (e) {
    console.error(e);
    res.status(500).send('Error handling callback');
  }
});
