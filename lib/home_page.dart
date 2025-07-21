import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dark_theme_page.dart';
import 'sermons_page.dart';
import 'announcements_page.dart';
import 'events_page.dart';
import 'bible_page.dart';
import 'more_page.dart';
import 'payment_details_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'faq_page.dart';
import 'transaction_history_page.dart';
import 'rate_app_helper.dart';
import 'notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String churchName = '';
  bool isLoading = true;

  final List<Map<String, dynamic>> features = const [
    {'title': 'Give Offering', 'icon': Icons.favorite, 'color': Colors.green},
    {'title': 'Sermons', 'icon': Icons.record_voice_over, 'color': Colors.deepPurple},
    {'title': 'Announcements', 'icon': Icons.announcement, 'color': Colors.blue},
    {'title': 'Events', 'icon': Icons.event, 'color': Colors.orange},
    {'title': 'Bible', 'icon': Icons.menu_book, 'color': Colors.brown},
    {'title': 'More', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          userName = doc['name'] ?? 'User';
          churchName = doc['church'] ?? 'Your Church';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('FAQ'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQPage())),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Transaction History'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionHistoryPage())),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Theme'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DarkThemePage())),
            ),
            ListTile(
              leading: const Icon(Icons.star_rate),
              title: const Text('Rate App'),
              onTap: () => openAppRating(),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
                Future.delayed(const Duration(milliseconds: 500), () {
                  Navigator.pushReplacementNamed(context, '/login');
                });
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Home', style: TextStyle(color: Colors.black)),
        actions: [
  StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('isRead', isEqualTo: false)
        .snapshots(),
    builder: (context, snapshot) {
      final int unreadCount = snapshot.data?.docs.length ?? 0;

      return Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
          if (unreadCount > 0)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    },
  ),
],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Image.asset('assets/icon/app_icon.png', height: 80)),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome back, $userName!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    churchName,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: features.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = features[index];
                      return GestureDetector(
                        onTap: () {
                          switch (item['title']) {
                            case 'Give Offering':
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentDetailsPage()));
                              break;
                            case 'Sermons':
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SermonsPage()));
                              break;
                            case 'Announcements':
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsPage()));
                              break;
                            case 'Events':
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const EventsPage()));
                              break;
                            case 'Bible':
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const BiblePage()));
                              break;
                            case 'More':
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const MorePage()));
                              break;
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: item['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: item['color']),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(item['icon'], size: 40, color: item['color']),
                              const SizedBox(height: 12),
                              Text(
                                item['title'],
                                style: TextStyle(fontWeight: FontWeight.bold, color: item['color']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
