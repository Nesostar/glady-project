import 'package:flutter/material.dart';
import 'payment_success_page.dart';
import 'payment_service.dart';

class PaymentConfirmationPage extends StatefulWidget {
  final double amount;
  final String method;

  const PaymentConfirmationPage({
    super.key,
    required this.amount,
    required this.method,
  });

  @override
  State<PaymentConfirmationPage> createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  bool _isLoading = false;
  String? _error;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    // Dismiss keyboard before processing
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Validate phone number format
      if (!PaymentService.isValidTanzanianPhone(_phoneController.text)) {
        setState(() => _error =
            'Please enter a valid Tanzanian phone number (e.g., 0712345678)');
        return;
      }

      // Format phone number
      final formattedPhone =
          PaymentService.formatPhoneNumber(_phoneController.text);

      // Use the new ZenoPay API method
      final result = await PaymentService.processMobileMoneyPayment(
        orderId: PaymentService.generateOrderId(),
        buyerEmail:
            'customer@example.com', // You might want to get this from user profile
        buyerName:
            'Church Member', // You might want to get this from user profile
        buyerPhone: formattedPhone,
        amount: widget.amount,
      );

      if (!mounted) return;

      if (result['success']) {
        final transactionId = result['data']['transaction_id'] ??
            result['data']['order_id'] ??
            'Unknown';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(
              amount: widget.amount.toStringAsFixed(2),
              method: widget.method,
              transactionId: transactionId,
              destinationAccount: 'Mobile Money',
            ),
          ),
        );
      } else {
        setState(() => _error = result['message'] ?? 'Payment failed');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _parseError(e.toString()));

      // Auto-scroll to error message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _parseError(String error) {
    if (error.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again';
    } else if (error.contains('insufficient funds')) {
      return 'Insufficient mobile money balance. Please top up and try again';
    } else if (error.contains('invalid phone') || error.contains('255')) {
      return 'Please enter a valid Tanzanian phone number (e.g., 0712345678)';
    } else if (error.contains('network error')) {
      return 'Network connection failed. Please check your internet';
    } else if (error.contains('processing failed')) {
      return 'Payment processor error. Please try again later';
    }
    return 'Payment failed: ${error.replaceAll('Exception: ', '').replaceAll('Payment failed: ', '')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Confirm Payment'),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Payment Summary Card
                          Card(
                            elevation: 2,
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(
                                      _getMethodIcon(),
                                      size: 32,
                                      color: Colors.green[700],
                                    ),
                                    title: Text(
                                      'Payment Method',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    subtitle: Text(
                                      widget.method.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Text(
                                      '${widget.amount.toStringAsFixed(2)} TZS',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  const ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(Icons.account_balance),
                                    title: Text('Settlement Account'),
                                    subtitle: Text('NMB Bank •••••36998'),
                                    trailing: Icon(Icons.verified,
                                        color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Phone Input Section
                          Text(
                            'Enter Mobile Number',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hintText: '0712345678',
                              prefixText: '+255 ',
                              prefixIcon: const Icon(Icons.phone_android),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (!RegExp(r'^[0-9]{9}$').hasMatch(value)) {
                                return 'Enter 9 digits (without +255)';
                              }
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'We\'ll send a payment request to this number',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ),

                          // Error Display
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[100]!),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const Spacer(),

                          // Pay Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _processPayment,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.green[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'CONFIRM PAYMENT',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _getMethodIcon() {
    switch (widget.method.toLowerCase()) {
      case 'mpesa':
        return Icons.phone_iphone;
      case 'tigopesa':
        return Icons.phone_android;
      case 'airtelmoney':
        return Icons.phone;
      default:
        return Icons.payment;
    }
  }
}
