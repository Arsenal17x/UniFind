import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart'; // ✅ ADD THIS

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isDark = false; // ✅ THEME STATE

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [

            // --- HEADER SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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

                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    backgroundImage:
                    const AssetImage("assets/anshul_profile.jpg"),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Anshul Rana",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    "anshul@gmail.com",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "⭐ New Member  •  Member since August 2025",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _buildActionTile(
                    icon: Icons.edit,
                    title: "Edit Profile",
                    subtitle: "Update your profile information",
                  ),

                  _buildActionTile(
                    icon: Icons.settings,
                    title: "Settings",
                    subtitle: "Manage your preferences",
                  ),

                  // 🌙 THEME TOGGLE


                  _buildActionTile(
                    icon: Icons.help_outline,
                    title: "Help & Support",
                    subtitle: "Get help or contact support",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- SIGN OUT BUTTON ---
            TextButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut(); // ✅ SIGN OUT

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => AnimatedLoginPage()),
                      (route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                "Sign Out",
                style: TextStyle(color: Colors.red),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
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
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap, // 👈 ADD THIS
  }) {
    return Card(
      color: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black)),
        subtitle: Text(subtitle,
            style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}