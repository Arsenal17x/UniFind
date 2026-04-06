import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClaimPage extends StatefulWidget {
  final String itemId;
  final String itemName;
  final String foundBy;
  final String category;

  const ClaimPage({
    super.key,
    required this.itemId,
    required this.itemName,
    required this.foundBy,
    required this.category,
  });

  @override
  State<ClaimPage> createState() => _ClaimPageState();
}

class _ClaimPageState extends State<ClaimPage> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  bool isLoading = false;

  final Map<String, List<String>> securityQuestions = {
    "Electronics": [
      "What is the brand?",
      "What is the color?",
      "Any lock/password detail?",
    ],
    "Documents": [
      "What type of document?",
      "Name on the document?",
      "Any ID number detail?",
    ],
    "Accessories": [
      "Color of the item?",
      "Any unique mark?",
      "Material type?",
    ],
    "Personal Belongings": [
      "What was inside?",
      "Color of the item?",
      "Any special feature?",
    ],
  };

  List<TextEditingController> answerControllers = [];

  @override
  void initState() {
    super.initState();

    final questions = securityQuestions[widget.category] ?? [];

    answerControllers =
        List.generate(questions.length, (_) => TextEditingController());
  }

  Future<void> submitClaim() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? {};

    if (descriptionController.text.isEmpty ||
        locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    await FirebaseFirestore.instance.collection('claims').add({
      "name": userData['name'] ?? "",
      "email": userData['email'] ?? "",
      "phone": userData['contact'] ?? "",
      "itemId": widget.itemId,
      "itemName": widget.itemName,
      "claimerId": user.uid,
      "description": descriptionController.text,
      "location": locationController.text,
      "status": "pending",
      "foundBy": widget.foundBy,
      "category": widget.category,
      "answers": answerControllers.map((c) => c.text).toList(),
      "createdAt": FieldValue.serverTimestamp(),
    });

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Claim submitted successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final questions = securityQuestions[widget.category] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Claim Item"),
      ),
      resizeToAvoidBottomInset: true, // 🔥 FIX
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16, // 🔥 FIX
        ),
        child: Column(
          children: [
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Describe the item (proof)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Where did you lose it?",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Column(
              children: List.generate(questions.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: answerControllers[index],
                    decoration: InputDecoration(
                      labelText: questions[index],
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitClaim,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Claim"),
              ),
            )
          ],
        ),
      ),
    );
  }
}