import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final Set<String> _confirming = {};

  /// Format timestamp to readable string
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  /// Export to PDF
  void exportToPDF(List<QueryDocumentSnapshot> transactions) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Transaction Report', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            ...transactions.map((txn) {
              final data = txn.data() as Map<String, dynamic>;
              final txnId = data['id'] ?? data['transaction_id'] ?? 'N/A';
              final email = data['email'] ?? 'N/A';
              final amount = data['amount'] ?? '0';
              final status = data['status'] ?? 'N/A';
              final date = _formatTimestamp(data['timestamp']);

              return pw.Text(
                "Txn: $txnId | TSH $amount | $status | $email | $date",
                style: const pw.TextStyle(fontSize: 12),
              );
            }).toList(),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  /// Confirm Transaction and notify user
  Future<void> confirmTransaction(String docId, Map<String, dynamic> data) async {
    final txnId = data['id'] ?? data['transaction_id'] ?? 'N/A';
    final userId = data['userId'];
    final amount = data['amount'] ?? '0';

    setState(() {
      _confirming.add(docId);
    });

    // Update transaction status
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(docId)
        .update({'status': 'Confirmed'});

    // Send notification only if userId exists
    if (userId != null && userId.toString().isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': 'Transaction Confirmed',
        'message': 'Your transaction of TSH $amount has been approved.',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'type': 'transaction',
      });
    }

    setState(() {
      _confirming.remove(docId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transactions")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final transactions = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...transactions.map((txn) {
                final data = txn.data() as Map<String, dynamic>;
                final txnId = data['id'] ?? data['transaction_id'] ?? 'N/A';
                final isConfirmed = data['status'] == 'Confirmed';
                final isProcessing = _confirming.contains(txn.id);

                final amount = data['amount'] ?? '0';
                final email = data['email'] ?? 'Unknown';
                final status = data['status'] ?? 'Pending';
                final timestamp = _formatTimestamp(data['timestamp']);

                return Card(
                  child: ListTile(
                    title: Text("Txn: $txnId"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Amount: TSH $amount"),
                        Text("Email: $email"),
                        Text("Time: $timestamp"),
                        Text("Status: $status"),
                      ],
                    ),
                    trailing: isConfirmed
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : isProcessing
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  confirmTransaction(txn.id, data);
                                },
                                child: const Text("Approve"),
                              ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => exportToPDF(transactions),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Export to PDF"),
              ),
            ],
          );
        },
      ),
    );
  }
}
