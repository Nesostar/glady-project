import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TransactionsPage extends StatelessWidget {
  TransactionsPage({super.key});

  final List<Map<String, dynamic>> transactions = [
    {"id": "#TXN001", "amount": 2000, "status": "Confirmed"},
    {"id": "#TXN002", "amount": 1500, "status": "Pending"},
  ];

  void exportToPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(build: (context) => pw.Center(child: pw.Text('Transaction Report'))),
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transactions")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...transactions.map((txn) => ListTile(
                title: Text("${txn['id']} - KES ${txn['amount']}"),
                subtitle: Text("Status: ${txn['status']}"),
                trailing: Icon(
                  txn['status'] == "Confirmed"
                      ? Icons.check_circle
                      : Icons.hourglass_bottom,
                  color: txn['status'] == "Confirmed" ? Colors.green : Colors.orange,
                ),
              )),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: exportToPDF,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Export to PDF"),
          ),
        ],
      ),
    );
  }
}
