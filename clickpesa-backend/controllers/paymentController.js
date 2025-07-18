import {
  initiatePaymentRequest,
  checkStatus
} from '../services/clickPesaService.js';

export const initiatePayment = async (req, res) => {
  const { amount, currency, phone_number, payment_method, description } = req.body;

  try {
    const result = await initiatePaymentRequest({ amount, currency, phone_number, payment_method, description });
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const checkPaymentStatus = async (req, res) => {
  const { transactionId } = req.params;

  try {
    const status = await checkStatus(transactionId);
    res.json({ status });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
