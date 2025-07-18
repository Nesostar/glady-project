import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_receipt_page.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String amount;
  final String method;

  const PaymentSuccessPage({
    super.key,
    required this.amount,
    required this.method, required String transactionId, required String destinationAccount,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  String? name, church, phone;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          name = data['name'] ?? 'N/A';
          church = data['church'] ?? 'N/A';
          phone = data['phone'] ?? 'N/A';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = _formattedDateTime();
    final transactionId = "TXN${DateTime.now().millisecondsSinceEpoch}";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 80, color: Colors.green),
                    const SizedBox(height: 20),
                    const Text(
                      "Payment Successful!",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${widget.amount} TZS",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(widget.method),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentReceiptPage(
                              name: name ?? '',
                              church: church ?? '',
                              phone: phone ?? '',
                              transactionId: transactionId,
                              amount: double.tryParse(widget.amount) ?? 0.0,
                              method: widget.method,
                              date: date,
                            ),
                          ),
                        );
                      },
                      child: const Text("View Receipt"),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("SMS Notification sent")),
                        );
                      },
                      child: const Text("Send SMS Notification"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: const Text("Done"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  static String _formattedDateTime() {
    final now = DateTime.now();
    return "${_weekdayName(now.weekday)}, ${_monthName(now.month)} ${now.day}, ${now.year}\n"
        "${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
  }

  static String _weekdayName(int weekday) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[weekday - 1];
  }

  static String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
