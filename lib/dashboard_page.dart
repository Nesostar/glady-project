import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  // ignore: library_private_types_in_public_api
  final List<_OfferingData> data = [
    _OfferingData('Mon', 30000),
    _OfferingData('Tue', 45000),
    _OfferingData('Wed', 25000),
    _OfferingData('Thu', 38000),
    _OfferingData('Fri', 50000),
  ];

  // Find max amount to normalize bar heights
  double get maxAmount => data.map((d) => d.amount).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Offerings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: data.map((offering) {
                  final barHeight = (offering.amount / maxAmount) * 200; // max bar height = 200
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Ksh ${(offering.amount / 1000).toStringAsFixed(0)}K',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 30,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        offering.day,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferingData {
  final String day;
  final double amount;

  _OfferingData(this.day, this.amount);
}
