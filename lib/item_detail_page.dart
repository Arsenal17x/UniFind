import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    bool isFound = item['status'] == 'Found';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Name
            Text(
              item['title'] ?? "",
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // 🔹 Category
            Text(
              "Category: ${item['category'] ?? "N/A"}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 10),

            // 🔹 Description
            Text(
              "Description: ${item['description'] ?? "No description"}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 10),

            // 🔹 Location
            Text(
              "Location: ${item['location'] ?? ""}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 10),

            // 🔹 Status
            Text(
              "Status: ${item['status']}",
              style: TextStyle(
                color: isFound ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 Start Chat Button (UPDATED LOGIC ONLY)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final userId = item['userId'];

                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No user info available")),
                    );
                    return;
                  }

                  try {
                    final doc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get();

                    if (!doc.exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User data not found")),
                      );
                      return;
                    }

                    final userData = doc.data()!;

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Contact Finder"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: ${userData['name'] ?? ""}"),
                            Text("Phone: ${userData['contact'] ?? ""}"),
                            Text("Email: ${userData['email'] ?? ""}"),
                            Text("Course: ${userData['course'] ?? ""}"),
                            Text("Semester: ${userData['semester'] ?? ""}"),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );

                  } catch (e) {
                    print("ERROR: $e");
                  }
                },
                child: const Text("Contact Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}