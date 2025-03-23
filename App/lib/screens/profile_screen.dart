// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:baigan/theme/app_colors.dart';
import 'package:baigan/widgets/custom_appbar.dart';

// Import your new widgets
import 'package:baigan/widgets/profile_screen_section_header_widget.dart';
import 'package:baigan/widgets/profile_screen_info_card.dart';
import 'package:baigan/widgets/profile_screen_info_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = "";
  String phone = "";
  String email = "";
  String bloodType = "O+";
  String allergies = "None";
  String medicalCondition = "None";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Set email from auth
        email = currentUser.email ?? "";

        // Get additional user data from Firestore
        final userData = await _firestore.collection('users').doc(currentUser.uid).get();

        if (userData.exists) {
          setState(() {
            name = userData.get('name') ?? "User";
            phone = userData.get('phone') ?? "";
            bloodType = userData.get('bloodType') ?? "O+";
            allergies = userData.get('allergies') ?? "None";
            medicalCondition = userData.get('medicalCondition') ?? "None";
            isLoading = false;
          });
        } else {
          // Create user document if it doesn't exist
          await _firestore.collection('users').doc(currentUser.uid).set({
            'name': currentUser.displayName ?? "User",
            'email': currentUser.email ?? "",
            'phone': "",
            'business': "",
            'bloodType': "O+",
            'allergies': "None",
            'medicalCondition': "None",
          });

          // Set default values
          setState(() {
            name = currentUser.displayName ?? "User";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load user data. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> editField(String field, String hint) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade200.withOpacity(0.95),
        title: Text(
          "Edit $hint",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            hintText: field,
            hintStyle: const TextStyle(fontSize: 18, color: Colors.grey),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          onChanged: (value) => newValue = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ),
        ],
      ),
    );

    if (newValue.isNotEmpty) {
      try {
        final User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          // Update value in state
          setState(() {
            if (hint == 'Name') {
              name = newValue;
            } else if (hint == 'Phone') {
              phone = newValue;
            } else if (hint == 'Email') {
              email = newValue;
            } else if (hint == 'Blood Type') {
              bloodType = newValue;
            } else if (hint == 'Allergies') {
              allergies = newValue;
            } else if (hint == 'Medical Condition') {
              medicalCondition = newValue;
            }
          });

          // Update in Firestore
          Map<String, dynamic> updateData = {};
          if (hint == 'Name') {
            updateData['name'] = newValue;
          } else if (hint == 'Phone') {
            updateData['phone'] = newValue;
          } else if (hint == 'Business') {
            updateData['business'] = newValue;
          } else if (hint == 'Blood Type') {
            updateData['bloodType'] = newValue;
          } else if (hint == 'Allergies') {
            updateData['allergies'] = newValue;
          } else if (hint == 'Medical Condition') {
            updateData['medicalCondition'] = newValue;
          }

          // Only update email in Auth if email is changed
          if (hint == 'Email') {
            await currentUser.updateEmail(newValue);
            updateData['email'] = newValue;
          }

          // Update Firestore document
          await _firestore.collection('users').doc(currentUser.uid).update(updateData);

          Get.snackbar(
            'Success',
            '$hint updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: const EdgeInsets.all(10),
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to update $hint. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Profile',
        ),
        backgroundColor: Colors.grey.shade100,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // -- Profile Header (inline or separate widget) --
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Your user image, name, email, etc.
                        // ...
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Personal Information Section
                const SectionHeader(title: 'Personal Information'),
                InfoCard(
                  children: [
                    InfoRow(
                      icon: Icons.person,
                      label: 'Name',
                      value: name,
                      onTap: () => editField(name, 'Name'),
                    ),
                    InfoRow(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: phone.isEmpty ? "Add Phone" : phone,
                      onTap: () => editField(phone, 'Phone'),
                    ),
                    InfoRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: email,
                      onTap: () => editField(email, 'Email'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Medical Information Section
                const SectionHeader(title: 'Medical Information'),
                InfoCard(
                  children: [
                    InfoRow(
                      icon: Icons.bloodtype,
                      label: 'Blood Type',
                      value: bloodType,
                      onTap: () => editField(bloodType, 'Blood Type'),
                      isImportant: true,
                    ),
                    InfoRow(
                      icon: Icons.warning_amber_rounded,
                      label: 'Allergies',
                      value: allergies,
                      onTap: () => editField(allergies, 'Allergies'),
                      isImportant: true,
                    ),
                    InfoRow(
                      icon: Icons.medical_services,
                      label: 'Medical Condition',
                      value: medicalCondition,
                      onTap: () => editField(medicalCondition, 'Medical Condition'),
                      isImportant: true,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Sign Out Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _auth.signOut();
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}