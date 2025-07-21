import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

class SermonsPage extends StatelessWidget {
  const SermonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sermons')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Sermon')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No sermons available'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final content = data['content'] ?? '[No content]';
              final fileUrl = data['fileUrl'];

              return Card(
                child: ListTile(
                  title: Text(content),
                  trailing: fileUrl != null ? const Icon(Icons.play_circle_fill) : null,
                  onTap: fileUrl != null
                      ? () async {
                          final result = await OpenFilex.open(fileUrl);
                          if (result.type != ResultType.done) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to open file: ${result.message}")),
                            );
                          }
                        }
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
