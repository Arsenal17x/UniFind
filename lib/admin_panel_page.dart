import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  void updateStatus(String claimId, String status) async {
    await FirebaseFirestore.instance
        .collection('claims')
        .doc(claimId)
        .update({
      "status": status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('claims')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pending claims"));
          }

          final claims = snapshot.data!.docs;

          return ListView.builder(
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final doc = claims[index];
              final claim = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Item: ${claim['itemName'] ?? ""}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      Text("Description: ${claim['description'] ?? ""}"),
                      Text("Location: ${claim['location'] ?? ""}"),

                      const SizedBox(height: 10),

                      const Text(
                        "Contact Info:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 5),

                      Text("Name: ${claim['name'] ?? ""}"),
                      Text("Email: ${claim['email'] ?? ""}"),
                      Text("Phone: ${claim['phone'] ?? ""}"),

                      const SizedBox(height: 10),

                      const Text(
                        "User Answers:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 5),

                      ...List.generate(
                        (claim['answers'] ?? []).length,
                            (i) => Text("• ${claim['answers'][i]}"),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          // ✅ APPROVE BUTTON
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text("Item Returned?"),
                                  content: const Text(
                                      "Has the item been returned to the user?"),
                                  actions: [

                                    // ❌ NOT RETURNED
                                    TextButton(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('claims')
                                            .doc(doc.id)
                                            .update({"status": "approved"});

                                        await FirebaseFirestore.instance
                                            .collection('items')
                                            .doc(claim['itemId'])
                                            .update({"status": "Claimed"});

                                        Navigator.pop(dialogContext);

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text("Marked as Claimed")),
                                        );
                                      },
                                      child: const Text("No"),
                                    ),

                                    // ✅ RETURNED
                                    TextButton(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('claims')
                                            .doc(doc.id)
                                            .update({"status": "approved"});

                                        await FirebaseFirestore.instance
                                            .collection('items')
                                            .doc(claim['itemId'])
                                            .delete();

                                        Navigator.pop(dialogContext);

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Item Returned & Removed")),
                                        );
                                      },
                                      child: const Text("Yes"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text("Approve"),
                          ),

                          const SizedBox(width: 10),

                          // ❌ REJECT BUTTON
                          ElevatedButton(
                            onPressed: () =>
                                updateStatus(doc.id, "rejected"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text("Reject"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}