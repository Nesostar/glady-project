import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;
              final title = data['title'] ?? 'Notification';
              final message = data['message'] ?? '';
              final isRead = data['isRead'] ?? false;
              final notificationUserId = data['userId']; // optional user targeting

              // Show all task notifications (no userId) or personal notifications (matching user)
              if (notificationUserId != null && notificationUserId != userId) {
                return const SizedBox(); // skip unrelated personal notifications
              }

              return ListTile(
                title: Text(title),
                subtitle: Text(message),
                leading: Icon(
                  isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                  color: isRead ? Colors.grey : Colors.blue,
                ),
                trailing: isRead
                    ? null
                    : const Text("New", style: TextStyle(color: Colors.red)),
                onTap: () {
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(id)
                      .update({'isRead': true});
                },
              );
            },
          );
        },
      ),
    );
  }
}
