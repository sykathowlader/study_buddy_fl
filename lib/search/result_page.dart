import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy_fl/profile/profile_page.dart';
import 'package:study_buddy_fl/search/user_model.dart';

class ResultsPage extends StatelessWidget {
  final List<UserModel> users;

  const ResultsPage({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
// It will apppear as a list of users with their profile picture, name, university and course.
// clicking on the user will lead to the profile page
    return Scaffold(
      appBar: AppBar(title: Text('Search Results')),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          UserModel user = users[index];
          String subtitleText = '${user.course}, ${user.university}';
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.profileImageUrl ??
                  'https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg'),
            ),
            title: Text(user.fullName),
            subtitle: Text(subtitleText),
            onTap: () {
              bool isUserProfile = user.userId == currentUserId;

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                            userId: user.userId,
                            isUserProfile: isUserProfile,
                            modifyInterest: false,
                          )));
            },
          );
        },
      ),
    );
  }
}
