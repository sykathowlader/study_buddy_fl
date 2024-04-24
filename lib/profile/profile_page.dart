import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study_buddy_fl/profile/connection_list_screen.dart';
import 'package:study_buddy_fl/profile/connection_message_bars.dart';
import 'package:study_buddy_fl/profile/edit_profile.dart';
import 'package:study_buddy_fl/profile/interests_section.dart';
import 'package:study_buddy_fl/services/auth.dart';
import 'package:study_buddy_fl/services/profile_page_service.dart';
import 'package:study_buddy_fl/services/storage_service.dart';
import 'package:study_buddy_fl/services/user_database.dart';

// This is the profile page where the user can see its information and edit in case needed
class ProfilePage extends StatefulWidget {
  // this flag allows to know if the profile page is of the current logged in user, who
  // can perform special operations, such as editing user details
  final bool isUserProfile;
  final String userId;
  // this flag allows to know if the user can modify the interests
  final bool modifyInterest;

  const ProfilePage(
      {super.key,
      required this.userId,
      this.isUserProfile = true,
      required this.modifyInterest});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  //final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final ProfilePageServices _profilePageServices = ProfilePageServices();
  late StorageService _storageService;
  late UserDatabase _userDatabase;
  bool _isLoading = false;
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _universityController = TextEditingController();
  TextEditingController _courseController = TextEditingController();
  TextEditingController _studyLevelController = TextEditingController();
  String? _currentStudyLevel;
  Map<String, dynamic>? _userData;
  List<String> _interests = []; // List to hold interests
  TextEditingController _interestController =
      TextEditingController(); // Controller for the input field

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _universityController.dispose();
    _courseController.dispose();
    _studyLevelController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _storageService = StorageService(uid: widget.userId);
    _userDatabase = UserDatabase(uid: widget.userId);
    _fetchUserDataAndPopulateFields(); // fetching user data in init method
    fetchUserInterests();
  }

// method to fetch user interests
  Future<void> fetchUserInterests() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('userInterests')
        .doc(widget.userId)
        .get();

    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

    if (snapshot.exists && data != null && data.containsKey('interests')) {
      List<dynamic> interests = data['interests'];
      setState(() {
        _interests = List<String>.from(interests);
      });
    }
  }

// method to fetch users
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

  // method to fetch user data and populte the controllers that are responsible to show the data in the UI
  Future<void> _fetchUserDataAndPopulateFields() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    var userData = await fetchUserData();
    if (userData != null) {
      setState(() {
        _userData = userData;
        _fullNameController.text = userData['fullName'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _universityController.text = userData['university'] ?? '';
        _courseController.text = userData['course'] ?? '';
        _currentStudyLevel = userData['studyLevel'] ?? '';
        _isLoading = false; // Done loading
      });
    } else {
      setState(() {
        _isLoading = false; // Error or no data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (widget.isUserProfile)
            IconButton(
              //logout button
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                // Show a dialog to confirm log out
                bool confirmLogout = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Log Out'),
                          content: Text('Do you want to log out?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pop(true), // User pressed "Yes"
                              child: Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pop(false), // User pressed "No"
                              child: Text('No'),
                            ),
                          ],
                        );
                      },
                    ) ??
                    false; // Dialog returns false if dismissed

                // If user confirmed log out, then sign out and navigate
                if (confirmLogout) {
                  await _authService.signOut(); // Sign out the user
                  Navigator.of(context).pushReplacementNamed(
                      '/login'); // Navigate to sign-in screen
                }
              },
            ),
          if (widget.isUserProfile)
            IconButton(
                //edit button
                icon: Icon(Icons.edit),
                onPressed: () async {
                  if (_userData != null) {
                    // upon pressing the edit button a dialog will appear showing
                    // the pre existing data of the user. The user can modify these fields
                    // and then cancel or save.

                    EditProfileDialog.showEditDialog(
                      context: context,
                      fullNameController: _fullNameController,
                      emailController: _emailController,
                      universityController: _universityController,
                      courseController: _courseController,
                      currentStudyLevel: _currentStudyLevel!,
                      onSave: (String fullName, String email, String university,
                          String course, String studyLevel) async {
                        await _saveProfileInfo(
                            fullName, email, university, course, studyLevel);
                        await _fetchUserDataAndPopulateFields(); // Refetch and update UI
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
                                // when the user clicks on the picture picture  it will expand the picture
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      child: Container(
                                        width: double.maxFinite,
                                        child: Image.network(
                                          userData['profileImageUrl'] ??
                                              'https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  //displaying the profile picture
                                  radius: 50,
                                  backgroundImage: NetworkImage(
                                    userData['profileImageUrl'] ??
                                        'https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg',
                                  ),
                                ),
                              ),
                              if (widget.isUserProfile)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  // button to add or remove photo
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
                        //full name
                        Text(
                          userData['fullName'] ?? 'Name not available',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        //university
                        SizedBox(height: 8),
                        Text(userData['university'] ??
                            'University not available'),
                        SizedBox(height: 4),
                        //course
                        Text(userData['course'] ?? 'Course not available'),
                        SizedBox(height: 4),
                        //study level
                        Text('Study Level: ${userData['studyLevel']}'),
                        SizedBox(height: 10),

                        // If it's the user's Profile Page, a list of connection of that user will be shown
                        if (widget.isUserProfile)
                          FutureBuilder<int>(
                            future:
                                _profilePageServices.fetchConnectionsCount(),
                            builder: (context, connectionsSnapshot) {
                              if (connectionsSnapshot.connectionState ==
                                  ConnectionState.done) {
                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to the ConnectionsListScreen on tap
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ConnectionsListScreen(
                                                currentUserId: widget.userId),
                                      ),
                                    );
                                  },
                                  child: Text(
                                      "Connections: ${connectionsSnapshot.data}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        //if the profile page is of another user, for example from the search user page,
                        //then a connect and message option will be avaiable
                        if (!widget.isUserProfile)
                          ConnectionMessageBars(
                            targetUserId: widget.userId,
                          ),
                        SizedBox(height: 20),
                        InterestsSection(
                          userId: widget.userId,
                          modifyInterest: widget.modifyInterest,
                        ),
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

// saving the edit
  Future<void> _saveProfileInfo(String fullName, String email,
      String university, String course, String studyLevel) async {
    await _userDatabase.updateUserData(
      fullName: fullName,
      email: email,
      university: university,
      course: course,
      studyLevel: studyLevel,
    );
  }
}
