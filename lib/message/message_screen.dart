import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy_fl/message/message.dart';
import 'package:study_buddy_fl/profile/profile_page.dart';
import 'package:study_buddy_fl/search/user_model.dart';
import 'package:study_buddy_fl/services/messages_services.dart';

class MessageScreen extends StatefulWidget {
  final String receiverUserId;

  const MessageScreen({super.key, required this.receiverUserId});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final MessageService _messageService = MessageService();
  final ScrollController _scrollController = ScrollController();
  UserModel? receiverUser;

  @override
  void initState() {
    super.initState();
    fetchReceiverUserInfo();
  }

  void fetchReceiverUserInfo() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverUserId)
        .get();
    if (userSnapshot.exists) {
      setState(() {
        receiverUser = UserModel.fromFirestore(
            userSnapshot.data() as Map<String, dynamic>);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: receiverUser == null
            ? Text("Loading...")
            : GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        userId: widget.receiverUserId,
                        isUserProfile: false,
                        modifyInterest: false,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(receiverUser!
                              .profileImageUrl ??
                          'https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg'),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(receiverUser!.fullName,
                            style: TextStyle(fontSize: 18)),
                        Text(receiverUser!.university,
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messageService.getMessages(
                  currentUserId, widget.receiverUserId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var docList = snapshot.data!.docs;

                  // Check if the messages are loaded for the first time and scroll to the bottom
                  if (docList.isNotEmpty && !_scrollController.hasClients) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController
                            .jumpTo(_scrollController.position.maxScrollExtent);
                      }
                    });
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: docList.length,
                    itemBuilder: (context, index) {
                      Message message = Message.fromMap(
                          docList[index].data() as Map<String, dynamic>);
                      return _buildMessageItem(
                          message, message.senderId == currentUserId);
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Failed to load messages"));
                }

                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message message, bool isSender) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          color: isSender ? Colors.blue[200] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(message.text),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _messageService.sendMessage(
          widget.receiverUserId, _messageController.text.trim());
      _messageController.clear();
      //list scrolls to the bottom to show the latest message
      if (_scrollController.hasClients) {
        Future.delayed(Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
