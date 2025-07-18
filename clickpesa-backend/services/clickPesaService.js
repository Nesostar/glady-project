import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

let cachedToken = null;
let tokenExpiry = null;

const getToken = async () => {
  if (cachedToken && tokenExpiry && Date.now() < tokenExpiry) {
    return cachedToken;
  }

  const response = await axios.post('https://api.clickpesa.com/third-parties/generate-token', {}, {
    headers: {
      'client-id': process.env.CLICKPESA_CLIENT_ID,
      'api-key': process.env.CLICKPESA_API_KEY
    }
  });

  const token = response.data.token.replace(/^Bearer\s/, '');
  cachedToken = token;
  tokenExpiry = Date.now() + 59 * 60 * 1000;

  return token;
};

export const initiatePaymentRequest = async ({ amount, currency, phone_number, payment_method, description }) => {
  const token = await getToken();

  const body = {
    amount,
    currency,
    phone_number,
    payment_method,
    description
  };

  const headers = {
    'Authorization': `Bearer ${token}`,
    'Client-Id': process.env.CLICKPESA_CLIENT_ID,
    'Content-Type': 'application/json'
  };

  const response = await axios.post('https://api.clickpesa.com/transactions/initiate-payment', body, { headers });

  return response.data;
};

export const checkStatus = async (transactionId) => {
  const token = await getToken();

  const response = await axios.get(`https://api.clickpesa.com/transactions/status/${transactionId}`, {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Client-Id': process.env.CLICKPESA_CLIENT_ID
    }
  });

  return response.data.status;
};
