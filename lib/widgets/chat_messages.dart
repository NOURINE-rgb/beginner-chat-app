import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});
  @override
  State<ChatMessages> createState() {
    return _ChatMessagesState();
  }
}

class _ChatMessagesState extends State<ChatMessages> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'sentAt',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No messages found."),
          );
        }
        final loadedMessages = snapshot.data!.docs;
        return Padding(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          child: ListView.builder(
            itemCount: loadedMessages.length,
            reverse: true,
            itemBuilder: (ctx, index) {
              final userMessage = loadedMessages[index].data()['text'];
              final userId = loadedMessages[index].data()['userId'];
              final isMe = userId == currentUserId;
              final nextUserId = (index + 1 < loadedMessages.length)
                  ? loadedMessages[index + 1].data()['userId']
                  : null;
              if (userId == nextUserId) {
                return MessageBubble.next(text: userMessage, isMe: isMe);
              } else {
                return MessageBubble.first(
                  isMe: isMe,
                  userName: loadedMessages[index].data()['username'],
                  text: userMessage,
                  imageUrl: loadedMessages[index].data()['imageUrl'],
                );
              }
            },
          ),
        );
      },
    );
  }
}








// nbadal if satatement li rani nbayan biha image and the user name