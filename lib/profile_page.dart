import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'edit_profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'help_support_page.dart';
import 'admin_panel_page.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,

      // 🔥 REAL-TIME FIRESTORE LISTENER
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final name = data['name'] ?? "No Name";
          final email =
              data['email'] ?? FirebaseAuth.instance.currentUser!.email ?? "";
          final profileImageUrl = data['profileImage'] ?? "";

          return SingleChildScrollView(
            child: Column(
              children: [

                // --- HEADER SECTION ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Colors.black87, Colors.black54]
                          : [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [

                      // 🔥 REAL-TIME PROFILE IMAGE
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        backgroundImage: profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : const AssetImage(
                            "assets/profpic.png")
                        as ImageProvider,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        email,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "⭐ welcome Back Nice To See You again",
                          style: TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatBox("2", "Items Reported"),
                          _buildStatBox("1", "People Helped"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- QUICK ACTIONS ---
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Quick Actions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _buildActionTile(
                        icon: Icons.edit,
                        title: "Edit Profile",
                        subtitle:
                        "Update your profile information",
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    EditProfilePage()),
                          );
                          // 🔥 NO NEED TO CALL fetch anymore
                        },
                      ),

                      _buildActionTile(
                        icon: Icons.settings,
                        title: "Settings",
                        subtitle: "Manage your preferences",
                      ),

                      _buildActionTile(
                        icon: Icons.help_outline,
                        title: "Help & Support",
                        subtitle: "Get help or contact support",
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => const HelpSupportPage(),
                              transitionsBuilder: (_, animation, __, child) {
                                return SlideTransition(
                                  position: Tween(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final role = data['role'] ?? "user";

                    if (role != "admin") return const SizedBox();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminPanelPage(),
                            ),
                          );
                        },
                        child: const Text("Admin Panel"),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // --- SIGN OUT BUTTON ---
                TextButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              AnimatedLoginPage()),
                          (route) => false,
                    );
                  },
                  icon:
                  const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.red),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildStatBox(String value, String label) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      color: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                isDark ? Colors.white : Colors.black)),
        subtitle: Text(subtitle,
            style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : Colors.black54)),
        trailing:
        const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}