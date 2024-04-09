import 'package:flutter/material.dart';
import 'package:study_buddy_fl/profile/profile_page.dart';
import 'package:study_buddy_fl/search/user_model.dart';
import 'package:study_buddy_fl/services/profile_page_service.dart';

class ConnectionsListScreen extends StatelessWidget {
  final String currentUserId;

  ConnectionsListScreen({required this.currentUserId});

  final ProfilePageServices _profilePageServices = ProfilePageServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connections'),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _profilePageServices.fetchUserConnections(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(child: Text('No connections found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              UserModel user = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profileImageUrl ??
                      'https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg'),
                ),
                title: Text(user.fullName),
                subtitle: Text("${user.course}, ${user.university}"),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        userId: user.userId,
                        modifyInterest: false,
                        isUserProfile: false,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
