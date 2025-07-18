import 'package:flutter/material.dart';
import 'payment_service.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false;

  void _startPayment() async {
    setState(() => _isLoading = true);

    try {
      final transactionId = await PaymentService.initiatePayment(
        amount: 3000,
        method: 'mobile_money',
        customerPhone: '255712345678',
      );

      setState(() => _isLoading = false);

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Payment Request Sent'),
          content: Text(
            'Dear user, a payment request of TZS 3000 has been sent to your mobile wallet. '
            'Please confirm the payment on your phone to complete the transaction.\n\n'
            'Transaction ID: $transactionId',
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _checkPaymentStatus(transactionId);
              },
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      // Show error dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Payment Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              child: Text('Retry'),
              onPressed: () {
                Navigator.pop(context);
                _startPayment();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  // 2. Polling payment status every 5 seconds (example)
  void _checkPaymentStatus(String transactionId) async {
    final maxAttempts = 12; // 1 minute timeout (12 x 5s)
    int attempts = 0;

    while (attempts < maxAttempts) {
      await Future.delayed(Duration(seconds: 5));

      // Call your backend status API (implement this)
      final status = await _getPaymentStatus(transactionId);

      if (status == 'SUCCESS') {
        _showResultDialog(success: true);
        return;
      } else if (status == 'FAILED') {
        _showResultDialog(success: false);
        return;
      }

      attempts++;
    }

    // Timeout reached
    _showResultDialog(success: false, message: 'Payment timed out. Please try again.');
  }

  Future<String> _getPaymentStatus(String transactionId) async {
    // TODO: Implement a call to your backend /payment-status?transactionId=...
    // For now, simulate:
    return 'PENDING';
  }

  void _showResultDialog({required bool success, String? message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(success ? 'Payment Successful' : 'Payment Failed'),
        content: Text(message ?? (success ? 'Thank you for your payment!' : 'Your payment failed.')),
        actions: [
          TextButton(
            child: Text(success ? 'Done' : 'Retry'),
            onPressed: () {
              Navigator.pop(context);
              if (!success) _startPayment();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Make Payment')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                child: Text('Pay TZS 3000'),
                onPressed: _startPayment,
              ),
      ),
    );
  }
}
