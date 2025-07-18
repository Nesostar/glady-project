import 'package:church_app/payment_details_page.dart';
import 'package:flutter/material.dart';
import 'payment_confirmation_page.dart';

class SelectPaymentMethodPage extends StatefulWidget {
  final double amount;
  final List<OfferingItem> offerings;
  final String currency;  // Added field

  const SelectPaymentMethodPage({
    super.key,
    required this.amount,
    required this.offerings,
    required this.currency,  // Required parameter
  });

  @override
  State<SelectPaymentMethodPage> createState() => _SelectPaymentMethodPageState();
}

class _SelectPaymentMethodPageState extends State<SelectPaymentMethodPage> {
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Payment Method"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSummaryCard(),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader("MOBILE MONEY"),
                _buildPaymentMethodTile("M-Pesa", "assets/mpesa.png", "Pay via M-Pesa Tanzania"),
                _buildPaymentMethodTile("Tigo Pesa", "assets/tigo.png", "Pay via Tigo Pesa"),
                _buildPaymentMethodTile("Airtel Money", "assets/airtel.png", "Pay via Airtel Money"),

                const SizedBox(height: 24),
                _buildSectionHeader("BANK TRANSFER"),
                _buildPaymentMethodTile("NMB Bank", "assets/nmb.png", "Direct transfer to NMB"),
                _buildPaymentMethodTile("CRDB Bank", "assets/crdb.png", "Direct transfer to CRDB"),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _selectedMethod == null ? null : _proceedToPayment,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'CONTINUE TO PAYMENT',
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
    );
  }

  Widget _buildSummaryCard() => Card(
        margin: const EdgeInsets.all(16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "PAYMENT SUMMARY",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.business, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "NESOSTAR TANZANIA",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "All payments settle to our NMB account",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              ...widget.offerings.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title),
                      Text(
                        "${item.amount?.toStringAsFixed(2)} ${widget.currency}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Amount:",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "${widget.amount.toStringAsFixed(2)} ${widget.currency}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildSectionHeader(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      );

  Widget _buildPaymentMethodTile(String name, String iconPath, String description) {
    final isSelected = _selectedMethod == name;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.green : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Image.asset(iconPath, width: 40),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => setState(() => _selectedMethod = name),
      ),
    );
  }

  void _proceedToPayment() {
    if (_selectedMethod == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentConfirmationPage(
          amount: widget.amount,
          method: _selectedMethod!.toLowerCase().replaceAll(' ', '_'),
        ),
      ),
    );
  }
}


