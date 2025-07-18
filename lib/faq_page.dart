import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'question': 'How do I make a payment?',
      'answer': 'To make a payment, go to the home page, select "Give Offering", and follow the instructions.'
    },
    {
      'question': 'How do I change my profile information?',
      'answer': 'Navigate to the Profile section from the menu and click on "Edit Profile".'
    },
    {
      'question': 'Is my payment information secure?',
      'answer': 'Yes, all payment data is encrypted and processed through secure channels.'
    },
    {
      'question': 'Can I view past transactions?',
      'answer': 'Yes, go to the Transaction History page from the side menu.'
    },
    {
      'question': 'How can I contact support?',
      'answer': 'Use the "More" section in the app to find contact details for our support team.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Text(
                faq['question']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(faq['answer']!),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
