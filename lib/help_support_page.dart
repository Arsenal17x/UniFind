import 'package:flutter/material.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Help & Support",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 🔍 SEARCH HEADER
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "How can we help you today?",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search for topics or questions...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Common Questions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildFAQTile(
                    "How to report a lost item?",
                    "Navigate to the home screen and tap the '+' button in the bottom navigation bar. Fill in the item details, category, and location, then tap 'Report Lost Item'.",
                    Icons.report_gmailerrorred,
                  ),
                  _buildFAQTile(
                    "How to contact the person who found my item?",
                    "Once you find your item in the search or home feed, tap 'View Details'. You can then initiate a chat with the reporter using the 'Chat' button.",
                    Icons.chat_outlined,
                  ),
                  _buildFAQTile(
                    "Is my information safe?",
                    "Yes, we only share necessary details like the item description and location. Personal contact info is kept private until you choose to share it in chat.",
                    Icons.security,
                  ),
                  _buildFAQTile(
                    "How do I edit my report?",
                    "Go to your profile page, and look for 'My Reports' (coming soon). Currently, you can edit your profile details in the 'Edit Profile' section.",
                    Icons.edit_note,
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Contact Support",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactCard(
                          icon: Icons.email_outlined,
                          title: "Email Us",
                          subtitle: "support@unifind.com",
                          color: Colors.blue.shade50,
                          iconColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildContactCard(
                          icon: Icons.bug_report_outlined,
                          title: "Report Bug",
                          subtitle: "Send crash logs",
                          color: Colors.red.shade50,
                          iconColor: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Safety & Guidelines",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildGuidelineItem(Icons.location_on_outlined,
                      "Meet in well-lit, public campus locations."),
                  _buildGuidelineItem(Icons.people_outline,
                      "Bring a friend if meeting someone for the first time."),
                  _buildGuidelineItem(Icons.verified_user_outlined,
                      "Ask for specific details only the owner would know."),

                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      "UniFind Version 1.0.0",
                      style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: Colors.blueAccent),
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(title,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
