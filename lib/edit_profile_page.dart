import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  // 🔥 CONTROLLERS
  final nameController = TextEditingController();
  final studentIdController = TextEditingController();
  final universityController = TextEditingController();
  final courseController = TextEditingController();
  final yearController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // 🔥 IMAGE VARIABLES
  String profileImageUrl = "";
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // 🔥 LOAD USER DATA FROM FIRESTORE
  void loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        setState(() {
          nameController.text = data['name'] ?? '';
          studentIdController.text = data['studentId'] ?? '';
          universityController.text = data['university'] ?? '';
          courseController.text = data['course'] ?? '';
          yearController.text = data['year'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phone'] ?? '';
          profileImageUrl = data['profileImage'] ?? "";
        });
      }
    }
  }

  // 🔥 FIXED IMAGE PICK + UPLOAD
  Future<void> pickAndUploadImage() async {
    try {
      final pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      File imageFile = File(pickedFile.path);

      setState(() {
        _image = imageFile;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images/${user.uid}.jpg');

      UploadTask uploadTask = ref.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      print("✅ IMAGE URL: $downloadUrl");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'profileImage': downloadUrl,
      }, SetOptions(merge: true));

      setState(() {
        profileImageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Image Updated")),
      );

    } catch (e) {
      print("❌ Upload Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image upload failed")),
      );
    }
  }

  // 🔥 REUSABLE TEXT FIELD (NO DESIGN CHANGE)
  Widget buildTextField(String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 🔥 SAVE DATA TO FIRESTORE
  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': nameController.text,
        'studentId': studentIdController.text,
        'university': universityController.text,
        'course': courseController.text,
        'year': yearController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'profileImage': profileImageUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Edit Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // --- MAIN CARD ---
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [

                        // 🔥 EDITABLE PROFILE IMAGE
                        GestureDetector(
                          onTap: pickAndUploadImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundImage: _image != null
                                    ? FileImage(_image!)
                                    : (profileImageUrl.isNotEmpty
                                    ? NetworkImage(profileImageUrl)
                                    : const NetworkImage(
                                    "https://via.placeholder.com/150"))
                                as ImageProvider,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(Icons.edit,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // --- FORM FIELDS ---
                        buildTextField("Full Name", Icons.person, nameController),
                        buildTextField("Student ID", Icons.badge, studentIdController),
                        buildTextField("University", Icons.school, universityController),
                        buildTextField("Course / Major", Icons.book, courseController),
                        buildTextField("Graduation Year", Icons.calendar_today, yearController),
                        buildTextField("Email", Icons.email, emailController),
                        buildTextField("Phone Number", Icons.phone, phoneController),

                        const SizedBox(height: 20),

                        // --- SAVE BUTTON ---
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: saveProfile,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              "Save Changes",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // --- CANCEL ---
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
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