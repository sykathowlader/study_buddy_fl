import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy_fl/message/message.dart';

class MessageService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    // Get current user details
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    // Create a new message
    Message newMessage = Message(
      senderId: currentUserId,
      receiverId: receiverId,
      text: message,
      timestamp: timestamp,
    );

    // Generate a chat room ID based on user IDs
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // Ensure the chat room document exists with 'participantIds' array
    final chatRoomRef = _fireStore.collection('chat_rooms').doc(chatRoomId);
    await _fireStore.runTransaction((transaction) async {
      final chatRoomSnapshot = await transaction.get(chatRoomRef);
      if (!chatRoomSnapshot.exists) {
        // If the chat room doesn't exist, create it with 'participantIds'
        transaction.set(chatRoomRef, {
          'participantIds': [
            currentUserId,
            receiverId
          ], // Include both users in the participantIds array
          'createdAt':
              timestamp, // Optional: track when the chat room was created
        });
      }
      // Add the new message to the chat room's message collection
      transaction.set(
          chatRoomRef.collection('messages').doc(), newMessage.toMap());
    });
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");
    return _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
