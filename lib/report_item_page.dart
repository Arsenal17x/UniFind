import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportItemPage extends StatefulWidget {
  const ReportItemPage({super.key});

  @override
  State<ReportItemPage> createState() => _ReportItemPageState();
}

class _ReportItemPageState extends State<ReportItemPage> {
  bool isLost = true;
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;
  String? selectedLocation;

  Future<void> _pickImageFromCamera() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;

        await FirebaseFirestore.instance.collection('items').add({
          'title': itemNameController.text,
          'category': selectedCategory,
          'description': descriptionController.text,
          'location': selectedLocation ?? "",
          'status': isLost ? 'Lost' : 'Found',
          'userId': user?.uid, // 👈 added
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item uploaded successfully")),
        );

        Navigator.pop(context);

      } catch (e) {
        print("ERROR: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Report Item",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => isLost = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        isLost ? Colors.black : Colors.grey.shade200,
                        foregroundColor:
                        isLost ? Colors.white : Colors.black87,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                      ),
                      child: const Text("I Lost Something"),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => isLost = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        !isLost ? Colors.black : Colors.grey.shade200,
                        foregroundColor:
                        !isLost ? Colors.white : Colors.black87,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      child: const Text("I Found Something"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Image picker box
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 58, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    _selectedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _selectedImage!,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Icon(Icons.camera_alt_outlined,
                        size: 50, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text(
                      "Add photos to help identify the item",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _pickImageFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Choose Photos"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Item Details section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Item Details",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: itemNameController,
                      decoration: const InputDecoration(
                        labelText: "Item Name *",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? "Please enter item name" : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Category *",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: "Electronics", child: Text("Electronics")),
                        DropdownMenuItem(
                            value: "Personal Belongings",
                            child: Text("Personal Belongings")),
                        DropdownMenuItem(
                            value: "Accessories", child: Text("Accessories")),
                        DropdownMenuItem(
                            value: "Documents", child: Text("Documents")),
                      ],
                      onChanged: (value) => selectedCategory = value,
                      validator: (value) =>
                      value == null ? "Please select a category" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Location Details section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Location Details",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Where did you lose/find it?",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: "Library", child: Text("Library")),
                        DropdownMenuItem(value: "CR", child: Text("CR")),
                        DropdownMenuItem(
                            value: "Cafeteria", child: Text("Cafeteria")),
                        DropdownMenuItem(
                            value: "Lecture Hall 5",
                            child: Text("Lecture Hall 5")),
                        DropdownMenuItem(
                            value: "Parking Area",
                            child: Text("Parking Area")),
                      ],
                      onChanged: (value) => selectedLocation = value,
                      validator: (value) =>
                      value == null ? "Please select a location" : null,
                    ),
                  ],
                ),
              ),

              // ✅ ONLY CHANGE APPLIED HERE
              if (isLost) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Security Questions",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                            labelText: "Unique identifier"),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        decoration:
                        InputDecoration(labelText: "What’s inside?"),
                      ),
                    ],
                  ),
                ),
              ],

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text(
                    isLost ? "Report Lost Item" : "Report Found Item",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}