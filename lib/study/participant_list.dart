import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy_fl/profile/profile_page.dart';
import 'package:study_buddy_fl/search/user_model.dart';

class SessionParticipantsList extends StatelessWidget {
  final List<UserModel> participants;

  const SessionParticipantsList({Key? key, required this.participants})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current user's ID
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text('Participants'),
      ),
      body: ListView.builder(
        itemCount: participants.length,
        itemBuilder: (context, index) {
          UserModel user = participants[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.profileImageUrl ??
                  'https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg'),
            ),
            title: Text(user.fullName),
            subtitle: Text("${user.course}, ${user.university}"),
            onTap: () {
              // Determine if the tapped user is the current user
              bool isUserProfile = user.userId == currentUserId;

              // Navigate to ProfilePage with isUserProfile set based on the comparison
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userId: user.userId,
                    isUserProfile: isUserProfile,
                    modifyInterest:
                        false, // Pass the boolean based on the comparison
                    // Make sure you have a constructor parameter in ProfilePage to accept and handle this boolean value.
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
