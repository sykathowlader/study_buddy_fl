import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study_buddy_fl/profile/edit_profile.dart';
import 'package:study_buddy_fl/services/storage_service.dart';
import 'package:study_buddy_fl/services/user_database.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  late StorageService _storageService;
  late UserDatabase _userDatabase;
  bool _isLoading = false;
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _universityController = TextEditingController();
  TextEditingController _courseController = TextEditingController();
  TextEditingController _studyLevelController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _universityController.dispose();
    _courseController.dispose();
    _studyLevelController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize storageService and userDatabase with the user's UID
    _storageService = StorageService(uid: widget.userId);
    _userDatabase = UserDatabase(uid: widget.userId);
  }

  Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.userId).get();
      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                // Fetch user data
                var userData = await fetchUserData();
                if (userData != null) {
                  // Populate controllers with fetched data
                  _fullNameController.text = userData['fullName'] ?? '';
                  _emailController.text = userData['email'] ?? '';
                  _universityController.text = userData['university'] ?? '';
                  _courseController.text = userData['course'] ?? '';
                  _studyLevelController.text = userData['studyLevel'] ?? '';

                  EditProfileDialog.showEditDialog(
                    context: context,
                    fullNameController: _fullNameController,
                    emailController: _emailController,
                    universityController: _universityController,
                    courseController: _courseController,
                    studyLevelController: _studyLevelController,
                    onSave: () {
                      _saveProfileInfo();
                    },
                  );
                }
              }),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: fetchUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    var userData = snapshot.data!;
                    return Column(
                      children: [
                        Center(
                          // positioning a circle avatar below and an icon to change the profile pic on top
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              // adding a gesture detector to see the full profile picture
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      child: Container(
                                        width: double.maxFinite,
                                        child: Image.network(
                                          userData['profileImageUrl'] ??
                                              'https://via.placeholder.com/150',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      NetworkImage(userData['profileImageUrl']),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.add_a_photo,
                                      color: Colors.green),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SafeArea(
                                          child: Wrap(
                                            children: <Widget>[
                                              ListTile(
                                                leading:
                                                    Icon(Icons.photo_library),
                                                title: Text('Select Photo'),
                                                onTap: () {
                                                  _pickImage();
                                                  Navigator.of(context)
                                                      .pop(); // Close the bottom sheet
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(Icons.delete),
                                                title: Text('Remove Photo'),
                                                onTap: () {
                                                  _removeProfileImage();
                                                  Navigator.of(context)
                                                      .pop(); // Close the bottom sheet
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          userData['fullName'] ?? 'Name not available',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(userData['university'] ??
                            'University not available'),
                        SizedBox(height: 4),
                        Text(userData['course'] ?? 'Course not available'),
                        SizedBox(height: 4),
                        Text('Study Level: ${userData['studyLevel']}'),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
    );
  }

  Future<void> _pickImage() async {
    try {
      setState(() => _isLoading = true); // Start loading
      // user selects an image from their gallery
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        File imageFile = File(image.path);

        // Upload the image to Firebase Storage and get the download URL
        String? imageUrl = await _storageService.uploadProfileImage(imageFile);

        if (imageUrl != null) {
          // Update the user's profileImageUrl in Firestore
          await _userDatabase.updateUserProfileImageUrl(imageUrl);

          //  setState to trigger a UI refresh to display the new image immediately
          setState(() {});
        } else {
          print("Failed to upload image or retrieve its URL");
        }
      }
    } catch (e) {
      print("Failed to pick image: $e");
    } finally {
      setState(() => _isLoading = false); // Stop loading regardless of outcome
    }
  }

  Future<void> _removeProfileImage() async {
    // URL for the default image
    String defaultImageUrl =
        'https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg';

    try {
      setState(() => _isLoading = true); // Start loading
      // Delete the profile image from Firebase Storage
      await _storageService.deleteProfileImage();
      // Update the Firestore document for the user's profile with the default image URL
      await _userDatabase.updateUserProfileImageUrl(defaultImageUrl);
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false); // Stop loading
    }
  }

  void _saveProfileInfo() async {
    // Assuming you have a method to update user data in Firestore
    // For example, using an instance of a class that manages Firestore operations:
    await _userDatabase.updateUserData(
      fullName: _fullNameController.text,
      email: _emailController.text,
      university: _universityController.text,
      course: _courseController.text,
      studyLevel: _studyLevelController.text,
    );

    Navigator.of(context).pop(); // Close the dialog after saving
  }
}
