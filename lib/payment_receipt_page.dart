import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaymentReceiptPage extends StatelessWidget {
  final String name;
  final String church;
  final String phone;
  final String transactionId;
  final double amount;
  final String method;
  final String date;

  const PaymentReceiptPage({
    super.key,
    required this.name,
    required this.church,
    required this.phone,
    required this.transactionId,
    required this.amount,
    required this.method,
    required this.date,
  });

  Future<void> _generatePDF(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('🧾 Payment Receipt',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Transaction Date: $date'),
              pw.Divider(),
              pw.Text('Member Information', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Name: $name'),
              pw.Text('Church: $church'),
              pw.Text('Phone: $phone'),
              pw.Divider(),
              pw.Text('Payment Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Method: $method'),
              pw.Text('Total Amount: TZS ${amount.toStringAsFixed(2)}'),
              pw.SizedBox(height: 10),
              pw.Text('Transaction ID: $transactionId'),
              pw.SizedBox(height: 20),
              pw.Text('Thank you for your contribution!'),
            ],
          );
        },
      ),
    );

    // Display the print preview dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("🧾 Payment Receipt", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                Text("Transaction Date: $date"),
                const Divider(),
                const Text("Member Information", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text("Name: $name"),
                Text("Church: $church"),
                Text("Phone: $phone"),
                const Divider(),
                const Text("Payment Details", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Method: $method"),
                Text("Total Amount: TZS ${amount.toStringAsFixed(2)}"),
                const SizedBox(height: 10),
                const Text("Thank you for your contribution"),
                Text("Transaction ID: $transactionId"),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                    ElevatedButton(
                      onPressed: () => _generatePDF(context),
                      child: const Text("Download PDF"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
