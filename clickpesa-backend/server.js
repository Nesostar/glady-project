// server.js

import express from 'express';
import cors from 'cors';
import axios from 'axios';
import crypto from 'crypto'; // For generating checksum

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Root health check
app.get('/', (req, res) => {
  res.send('✅ ClickPesa Backend is running!');
});

// Handle form submission
app.post('/submit-form', (req, res) => {
  const formData = req.body;
  console.log('📥 Received form data:', formData);

  // Simulated transaction ID response
  res.json({
    message: 'Form submitted successfully',
    transaction_id: 'TX123456789',
  });
});

// ✅ Real: Initiate payment with ClickPesa API
app.post('/initiate-payment', async (req, res) => {
  const { amount, currency = 'TZS', phoneNumber, paymentMethod } = req.body;

  console.log('💰 Initiating payment with details:');
  console.log('Amount:', amount);
  console.log('Currency:', currency);
  console.log('Phone Number:', phoneNumber);
  console.log('Payment Method:', paymentMethod);

  const orderReference = `ORDER_${Date.now()}`;
  const secret = 'SKXE1m9g6JNBHKnInMd1FWoGiMnGD6xK6YjN1ccYNE'; // 🔐 Replace this with your real ClickPesa secret
  const token = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4NTllMjZhZjdkMjdkMDM2MzZmMzRlMCIsImFwcGxpY2F0aW9uX2NsaWVudF9pZCI6IklEVDFYd1VTUmhNMzZNVUlsWU90Z3NGYlR4UGRFZ1psIiwidmVyaWZpZWQiOnRydWUsImFwaV9hY2Nlc3MiOnRydWUsInVzZXJOYW1lIjoiMWRhMTg4YzQtMGYxZC00ODg4LTk0MjktMWUwZjQ4NWI0NWE2IiwiY2hlY2tzdW1FbmFibGVkIjp0cnVlLCJpYXQiOjE3NTI3NzExNjgsImV4cCI6MTc1Mjc3NDc2OH0.qvBF2gEw7ictOwiBAZKVlbC2F2vUiQLMmJD-pYAzHjI';

  // Generate checksum
  const checksum = crypto
    .createHash('sha256')
    .update(orderReference + amount + secret)
    .digest('hex');

  try {
    const response = await axios.post(
      'https://api.clickpesa.com/third-parties/payments/preview-ussd-push-request',
      {
        amount: amount.toString(),
        currency,
        orderReference,
        checksum,
        // Optional: include phoneNumber or paymentMethod if required by ClickPesa
      },
      {
        headers: {
          Authorization: token,
          'Content-Type': 'application/json',
        },
      }
    );

    console.log('✅ ClickPesa response:', response.data);
    res.json(response.data); // return ClickPesa's response to the frontend
  } catch (error) {
    console.error('❌ ClickPesa error:', error?.response?.data || error.message);
    res.status(500).json({
      error: 'Payment request failed',
      details: error?.response?.data || error.message,
    });
  }
});

// Payment status checker (dummy for now)
app.get('/payment-status', (req, res) => {
  const transactionId = req.query.transactionId;
  const paymentStatus = 'PENDING'; // You can improve this to check from ClickPesa or DB

  res.json({ transactionId, status: paymentStatus });
});

// Start server on all interfaces
app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Server running at http://192.168.43.243:${port}`);
});
