import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'select_payment_method_page.dart';

class PaymentDetailsPage extends StatelessWidget {
  const PaymentDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NESOSTAR Payments',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const PaymentDetailsScreen(),
    );
  }
}

class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({super.key});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final List<OfferingItem> _offeringItems = [
    OfferingItem(title: 'Tithe', category: 'Regular'),
    OfferingItem(title: 'Church Development', category: 'Project'),
    OfferingItem(title: 'Campmeeting', category: 'Event'),
  ];

  String _selectedCurrency = 'TZS';
  String _userName = '';
  String _userChurch = '';
  String _membershipType = '';
  bool _isLoading = true;

  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '');

  // We need a map to hold TextEditingControllers for each offering item’s amount,
  // so we can properly update & dispose of them.
  final Map<int, TextEditingController> _amountControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    // Initialize controllers for initial offering items
    for (int i = 0; i < _offeringItems.length; i++) {
      _amountControllers[i] = TextEditingController(
        text: _offeringItems[i].amount?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            _userName = doc['name'] ?? '';
            _userChurch = doc['church'] ?? '';
            _membershipType = doc['membershipType'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    }
  }

  double _calculateTotal() {
    return _offeringItems.fold<double>(
      0,
      // ignore: avoid_types_as_parameter_names
      (sum, item) => sum + (item.amount ?? 0),
    );
  }

  void _addNewOffering() {
    setState(() {
      _offeringItems.add(OfferingItem(title: '', category: 'Other'));
      final newIndex = _offeringItems.length - 1;
      _amountControllers[newIndex] = TextEditingController();
    });
  }

  void _updateCurrency(String? value) {
    if (value != null) {
      setState(() => _selectedCurrency = value);
    }
  }

  void _removeOffering(int index) {
    setState(() {
      _offeringItems.removeAt(index);
      _amountControllers[index]?.dispose();
      _amountControllers.remove(index);

      // Need to rebuild _amountControllers map keys for correct indices
      final newControllers = <int, TextEditingController>{};
      for (int i = 0; i < _offeringItems.length; i++) {
        if (_amountControllers.containsKey(i)) {
          newControllers[i] = _amountControllers[i]!;
        } else {
          newControllers[i] = TextEditingController(
            text: _offeringItems[i].amount?.toString() ?? '',
          );
        }
      }
      _amountControllers
        ..clear()
        ..addAll(newControllers);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewOffering,
            tooltip: 'Add offering',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserProfileCard(),
                  const SizedBox(height: 24),

                  const Text(
                    'OFFERINGS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ..._offeringItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final amountController = _amountControllers[index]!;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.title,
                                    decoration: const InputDecoration(
                                      labelText: 'Offering Title',
                                      isDense: true,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _offeringItems[index].title = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 120,
                                  child: TextField(
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Amount ($_selectedCurrency)',
                                      hintText: 'Enter amount',
                                      isDense: true,
                                      prefixText: _selectedCurrency == 'TZS'
                                          ? 'TZS '
                                          : '\$ ',
                                    ),
                                    onChanged: (value) {
                                      final cleanedValue =
                                          value.replaceAll(RegExp(r'[^0-9]'), '');
                                      final amount = int.tryParse(cleanedValue) ?? 0;
                                      setState(() {
                                        _offeringItems[index].amount = amount;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                DropdownButton<String>(
                                  value: item.category,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'Regular', child: Text('Regular')),
                                    DropdownMenuItem(
                                        value: 'Project', child: Text('Project')),
                                    DropdownMenuItem(
                                        value: 'Event', child: Text('Event')),
                                    DropdownMenuItem(
                                        value: 'Other', child: Text('Other')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _offeringItems[index].category = value;
                                      });
                                    }
                                  },
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeOffering(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const Divider(height: 40),

                  _buildTotalAmountCard(totalAmount),
                  const SizedBox(height: 24),

                  _buildCurrencyDropdown(),
                  const SizedBox(height: 32),

                  _buildProceedButton(totalAmount),
                ],
              ),
            ),
    );
  }

  Widget _buildUserProfileCard() => Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.church, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _userChurch,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.card_membership, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Membership: $_membershipType',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMMM d, y').format(DateTime.now()),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildTotalAmountCard(double total) => Card(
        color: Colors.green[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL AMOUNT:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatCurrency(total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildCurrencyDropdown() => DropdownButtonFormField<String>(
        value: _selectedCurrency,
        decoration: InputDecoration(
          labelText: 'Payment Currency',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        items: const [
          DropdownMenuItem(value: 'TZS', child: Text('Tanzanian Shilling (TZS)')),
          DropdownMenuItem(value: 'USD', child: Text('US Dollar (USD)')),
          DropdownMenuItem(value: 'EUR', child: Text('Euro (EUR)')),
        ],
        onChanged: _updateCurrency,
      );

  Widget _buildProceedButton(double totalAmount) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: totalAmount > 0 &&
                  _offeringItems.every((i) => i.title.trim().isNotEmpty)
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectPaymentMethodPage(
                        amount: totalAmount,
                        currency: _selectedCurrency,
                        offerings: _offeringItems,
                      ),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'PROCEED TO PAYMENT',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );

  String _formatCurrency(double amount) {
    switch (_selectedCurrency) {
      case 'USD':
        return '\$${_currencyFormat.format(amount)}';
      case 'EUR':
        return '€${_currencyFormat.format(amount)}';
      default:
        return 'TZS ${_currencyFormat.format(amount)}';
    }
  }
}

class OfferingItem {
  String title;
  int? amount;
  String category;

  OfferingItem({
    required this.title,
    this.amount,
    required this.category,
  });
}
