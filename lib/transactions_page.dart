import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TransactionsPage extends StatelessWidget {
  TransactionsPage({super.key});

  // Exporting transactions to PDF
  void exportToPDF(List<QueryDocumentSnapshot> transactions) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Text('Transaction Report', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            ...transactions.map((txn) {
              final data = txn.data() as Map<String, dynamic>;
              return pw.Text(
                "${data['id']} - KES ${data['amount']} - ${data['status']}",
              );
            }),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // Confirm a transaction and notify user
  Future<void> confirmTransaction(
      String docId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(docId)
        .update({'status': 'Confirmed'});

    // Add notification to user
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': data['userId'], // ensure transactions have userId
      'title': 'Your transaction ${data['id']} has been approved.',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
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
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final transactions = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...transactions.map((txn) {
                final data = txn.data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text("${data['id']} - KES ${data['amount']}"),
                    subtitle: Text("Status: ${data['status']}"),
                    trailing: data['status'] == 'Confirmed'
                        ? const Icon(Icons.check_circle, color: Colors.green)
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
