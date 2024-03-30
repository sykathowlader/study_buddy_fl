import 'package:flutter/material.dart';
import 'package:study_buddy_fl/profile/profile_page.dart';
import 'package:study_buddy_fl/search/user_model.dart';

class ResultsPage extends StatelessWidget {
  final List<UserModel> users;

  const ResultsPage({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              // Assuming you have a modified ProfilePage that accepts a userId
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                            userId: user.userId,
                            isUserProfile: false,
                            modifyInterest: false,
                          )));
            },
          );
        },
      ),
    );
  }
}
