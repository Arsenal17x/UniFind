import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'item_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Items"),
      ),
      body: Column(
        children: [

          // 🔍 SEARCH FIELD
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search items...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),
          ),

          // 📋 FIRESTORE DATA
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No items found"));
                }

                // 🔍 FILTER
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final title =
                  (doc['title'] ?? "").toString().toLowerCase();
                  final description =
                  (doc['description'] ?? "").toString().toLowerCase();

                  return title.contains(query.toLowerCase()) ||
                      description.contains(query.toLowerCase());
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("No matching items"));
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final item = filteredDocs[index];
                    bool isFound = item['status'] == 'Found';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(

                        // ✅ FIX APPLIED HERE
                        onTap: () {
                          final data =
                          item.data() as Map<String, dynamic>;
                          data['id'] = item.id; // 🔥 IMPORTANT FIX

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetailPage(
                                item: data,
                              ),
                            ),
                          );
                        },

                        leading: Icon(
                          isFound ? Icons.check_circle : Icons.search,
                          color: isFound ? Colors.green : Colors.red,
                        ),

                        title: Text(item['title'] ?? "No title"),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['location'] ?? ""),
                            Text(
                              item['description'] ?? "",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),

                        trailing: Container(
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
                              color: isFound
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}