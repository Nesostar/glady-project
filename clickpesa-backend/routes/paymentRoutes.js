import express from 'express';
import {
  initiatePayment,
  checkPaymentStatus
} from '../controllers/paymentController.js';

const router = express.Router();

router.post('/', initiatePayment); // /api/payments/
router.get('/status/:transactionId', checkPaymentStatus); // /api/payments/status/:id

export default router;
