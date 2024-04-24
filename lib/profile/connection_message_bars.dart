import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_buddy_fl/message/message_screen.dart';

class ConnectionMessageBars extends StatefulWidget {
  final String targetUserId; // ID of the user to connect with

  const ConnectionMessageBars({
    Key? key,
    required this.targetUserId,
  }) : super(key: key);

  @override
  _ConnectionMessageBarsState createState() => _ConnectionMessageBarsState();
}

class _ConnectionMessageBarsState extends State<ConnectionMessageBars> {
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    checkInitialConnection();
  }

//if the user is alreaady connected then Connected text will appear if not connect text will appear
  Future<void> checkInitialConnection() async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final DocumentReference connectionDoc =
        FirebaseFirestore.instance.collection('connections').doc(currentUserId);

    final DocumentSnapshot docSnapshot = await connectionDoc.get();

    if (docSnapshot.exists) {
      List connectionsId = docSnapshot['connectionsId'] ?? [];
      setState(() {
        isConnected = connectionsId.contains(widget.targetUserId);
      });
    }
  }

// method to connect users
  Future<void> toggleConnection() async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final DocumentReference connectionDoc =
        FirebaseFirestore.instance.collection('connections').doc(currentUserId);

    final DocumentSnapshot docSnapshot = await connectionDoc.get();

    if (docSnapshot.exists) {
      List connectionsId = docSnapshot['connectionsId'] ?? [];
      if (connectionsId.contains(widget.targetUserId)) {
        connectionsId.remove(widget.targetUserId);
        isConnected = false;
      } else {
        connectionsId.add(widget.targetUserId);
        isConnected = true;
      }
      await connectionDoc.update({'connectionsId': connectionsId});
    } else {
      await connectionDoc.set({
        'userId': currentUserId,
        'connectionsId': [widget.targetUserId],
      });
      isConnected = true;
    }

    setState(() {}); // Update UI to reflect the change
  }

// when the curret user is looking at other user profile's he has to option, to connect and to message that user
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () async {
            await toggleConnection();
          },
          child: Text(isConnected ? 'Connected' : 'Connect'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isConnected ? Colors.grey : Colors.green,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MessageScreen(receiverUserId: widget.targetUserId),
              ),
            );
          },
          child: Text('Message'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }
}
