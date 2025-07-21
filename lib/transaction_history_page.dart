import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Map<String, dynamic>> transactions = [];
  bool isAdmin = false;
  bool isLoading = true;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadTransactionsFromFirestore();
  }

  Future<void> _loadTransactionsFromFirestore() async {
    if (user == null) return;

    try {
      // Check if current user is an admin
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user!.uid)
          .get();
      isAdmin = adminSnapshot.exists;

      Query query = FirebaseFirestore.instance
          .collection('transactions')
          .orderBy('timestamp', descending: true);

      if (!isAdmin) {
        query = query.where('userId', isEqualTo: user!.uid);
      }

      final snapshot = await query.get();

      setState(() {
        transactions = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['timestamp'] = data['timestamp']?.toDate();
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('❌ Failed to load transactions: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _generateReportPDF() async {
    final pdf = pw.Document();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Transaction Report', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            ...transactions.map(
              (tx) => pw.Text(
                '${tx['email'] ?? 'N/A'} | '
                'TSH ${tx['amount'] ?? '0'} | '
                '${tx['status'] ?? 'N/A'} | '
                '${tx['timestamp'] != null ? formatter.format(tx['timestamp']) : 'N/A'}',
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
      case 'Successful':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'All Transactions' : 'My Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: transactions.isEmpty ? null : _generateReportPDF,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text('No transactions found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return ListTile(
                      leading: Icon(Icons.receipt_long, color: _getStatusColor(tx['status'] ?? '')),
                      title: Text('TSH ${tx['amount'] ?? '0'}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${tx['status'] ?? 'Unknown'}'),
                          if (tx['email'] != null)
                            Text('Email: ${tx['email']}'),
                          if (tx['timestamp'] != null)
                            Text('Time: ${formatter.format(tx['timestamp'])}'),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
