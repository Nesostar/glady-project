import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final token = await ClickPesaApi().getToken();
      final response = await http.get(
        Uri.parse('https://api.clickpesa.com/transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Client-Id': ClickPesaApi().clientId,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          transactions = List<Map<String, dynamic>>.from(data['transactions']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch transactions: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching transactions: $e');
      setState(() => isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  Future<void> _generateReportPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Transaction Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              ...transactions.map(
                (tx) => pw.Text(
                  '${tx['date']} | ${tx['title'] ?? 'Transaction'} | ${tx['amount']} | ${tx['status']}',
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
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
                      title: Text(tx['title'] ?? 'Transaction'),
                      subtitle: Text(tx['date'] ?? ''),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(tx['amount'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            tx['status'] ?? '',
                            style: TextStyle(color: _getStatusColor(tx['status'] ?? ''), fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class ClickPesaApi {
  static final ClickPesaApi _instance = ClickPesaApi._internal();
  factory ClickPesaApi() => _instance;
  ClickPesaApi._internal();

  final String _clientId = 'IDT1XwUSRhM36MUIlYOtgsFbTxPdEgZl';
  final String _apiKey = 'SKXE1m9g6JNBHKnInMd1FWoGiMnGD6xK6YjN1ccYNE';

  String? _token;
  DateTime? _tokenExpiry;

  String get clientId => _clientId;

  Future<String> getToken() async {
    if (_token != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _token!;
    }

    final response = await http.post(
      Uri.parse('https://api.clickpesa.com/third-parties/generate-token'),
      headers: {
        'client-id': _clientId,
        'api-key': _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String rawToken = data['token'];
      _token = rawToken.replaceFirst(RegExp(r'^Bearer\s+'), '');
      _tokenExpiry = DateTime.now().add(const Duration(minutes: 59));
      return _token!;
    } else {
      throw Exception('Unauthorized: ${response.body}');
    }
  }
}
