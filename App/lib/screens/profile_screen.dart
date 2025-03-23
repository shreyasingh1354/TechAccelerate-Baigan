import 'package:flutter/material.dart';
import 'package:baigan/theme/app_colors.dart';
import 'package:baigan/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

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
        final userData =
            await _firestore.collection('users').doc(currentUser.uid).get();

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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          style: TextStyle(fontSize: 18),
          decoration: InputDecoration(
            hintText: field,
            hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
            focusedBorder: UnderlineInputBorder(
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
              )),
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
          await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .update(updateData);

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
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Profile',
        ),
        backgroundColor: Colors.grey.shade100,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Header with Image
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(60),
                                      child: _auth.currentUser?.photoURL != null
                                          ? Image.network(
                                              _auth.currentUser!.photoURL!,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return CircleAvatar(
                                                  radius: 60,
                                                  backgroundColor:
                                                      Colors.blue.shade200,
                                                  child: Text(
                                                    name.isNotEmpty
                                                        ? name[0].toUpperCase()
                                                        : "U",
                                                    style: TextStyle(
                                                      fontSize: 50,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : CircleAvatar(
                                              radius: 60,
                                              backgroundColor:
                                                  Colors.blue.shade200,
                                              child: Text(
                                                name.isNotEmpty
                                                    ? name[0].toUpperCase()
                                                    : "U",
                                                style: TextStyle(
                                                  fontSize: 50,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        // Add functionality to change profile picture
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                email,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to edit profile screen
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Edit Profile',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Personal Information Section
                      _buildSectionHeader('Personal Information'),
                      _buildInfoCard(
                        [
                          _buildInfoRow(
                            Icons.person,
                            'Name',
                            name,
                            () => editField(name, 'Name'),
                          ),
                          _buildInfoRow(
                            Icons.phone,
                            'Phone',
                            phone.isEmpty ? "Add Phone" : phone,
                            () => editField(phone, 'Phone'),
                          ),
                          _buildInfoRow(
                            Icons.email,
                            'Email',
                            email,
                            () => editField(email, 'Email'),
                          )
                        ],
                      ),

                      SizedBox(height: 24),

                      // Medical Information Section
                      _buildSectionHeader('Medical Information'),
                      _buildInfoCard(
                        [
                          _buildInfoRow(
                            Icons.bloodtype,
                            'Blood Type',
                            bloodType,
                            () => editField(bloodType, 'Blood Type'),
                            isImportant: true,
                          ),
                          _buildInfoRow(
                            Icons.warning_amber_rounded,
                            'Allergies',
                            allergies,
                            () => editField(allergies, 'Allergies'),
                            isImportant: true,
                          ),
                          _buildInfoRow(
                            Icons.medical_services,
                            'Medical Condition',
                            medicalCondition,
                            () => editField(
                                medicalCondition, 'Medical Condition'),
                            isImportant: true,
                          ),
                        ],
                      ),

                      SizedBox(height: 30),

                      // Sign Out Button
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _auth.signOut();
                          },
                          icon: Icon(Icons.logout, color: Colors.white),
                          label: Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap, {
    bool isImportant = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isImportant
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isImportant ? Colors.red : Colors.blue,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isImportant ? Colors.red.shade700 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
