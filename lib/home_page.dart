import 'package:flutter/material.dart';
import 'report_item_page.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'item_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportItemPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                "assets/app_logo.png",
                height: 55,
                width: 55,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "UniFind",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 27,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black87),
          SizedBox(width: 12),
        ],
      ),

      // --- BODY ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 Welcome Section
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("assets/profile.jpg"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .get(),
                    builder: (context, snapshot) {
                      String name = "User";

                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data =
                        snapshot.data!.data() as Map<String, dynamic>;
                        name = data['name'] ?? "User";
                      }

                      return Text(
                        "Welcome back, $name!",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🔥 Dynamic Cards
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .snapshots(),
              builder: (context, snapshot) {
                int lostCount = 0;
                int foundCount = 0;

                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final item = doc.data() as Map<String, dynamic>;

                    if (item['status'] == 'Lost') lostCount++;
                    if (item['status'] == 'Found') foundCount++;
                  }
                }

                return Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: "Lost Items",
                        subtitle: "$lostCount active lost reports",
                        buttonText: "View Lost Items",
                        color: Colors.blue.shade50,
                        buttonColor: Colors.blue,
                        icon: Icons.help_outline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DashboardCard(
                        title: "Items Found",
                        subtitle: "$foundCount active found reports",
                        buttonText: "View Found Items",
                        color: Colors.green.shade50,
                        buttonColor: Colors.green,
                        icon: Icons.search,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              "Recent Lost and Found Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // --- ITEMS LIST ---
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No items yet"));
                }

                final items = snapshot.data!.docs;

                return Column(
                  children: items.map((doc) {
                    final item = doc.data() as Map<String, dynamic>;
                    bool isFound = item['status'] == 'Found';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(Icons.inventory, size: 32),
                        title: Text(item['title'] ?? ""),
                        subtitle: Text(item['location'] ?? ""),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isFound
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['status'],
                                style: TextStyle(
                                  color: isFound ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      final data =
                                      item as Map<String, dynamic>;
                                      data['id'] = doc.id; // ✅ FIX

                                      return ItemDetailPage(item: data);
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                "View Details",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            )
          ],
        ),
      ),

      // --- BOTTOM NAV ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

// --- Dashboard Card (UNCHANGED) ---
class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final Color color;
  final Color buttonColor;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.color,
    required this.buttonColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: buttonColor, size: 32),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 8), // 🔥 CLEAN SPACING (NO BUTTON)
        ],
      ),
    );
  }
}