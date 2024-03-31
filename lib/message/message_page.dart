import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy_fl/message/message_screen.dart';
import 'package:study_buddy_fl/search/user_model.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Stream<List<UserModel>> getUserChats() {
    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .where('participantIds', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<UserModel> chatUsers = [];
      for (var doc in querySnapshot.docs) {
        var participantIds = List.from(doc['participantIds']);
        var otherUserId =
            participantIds.firstWhere((id) => id != currentUserId);
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherUserId)
            .get();
        if (userDoc.exists) {
          chatUsers.add(UserModel.fromFirestore(userDoc.data()!));
        }
      }
      return chatUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: getUserChats(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return Center(child: Text("No conversations found."));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profileImageUrl ??
                      'https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg'),
                ),
                title: Text(user.fullName),
                subtitle: Text("${user.course}, ${user.university}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MessageScreen(receiverUserId: user.userId),
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
