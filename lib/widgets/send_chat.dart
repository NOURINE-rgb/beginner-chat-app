import 'package:chat_app/setup_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SendChat extends StatefulWidget {
  const SendChat({super.key});
  @override
  State<SendChat> createState() {
    return _SendChatState();
  }
}

class _SendChatState extends State<SendChat> {
  final msgController = TextEditingController();
  @override
  void dispose() {
    msgController.dispose();
    super.dispose();
  }

  void submitMsg() async {
    if (msgController.text.trim().isEmpty) {
      return;
    }
    final text = msgController.text;
    msgController.clear();
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': text,
      'sentAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'imageUrl': userData.data()!['imageUrl'],
    });
    await HomePage.sendFCMMessage("not yet", text);
    // send it to firestore
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 1, bottom: 14, left: 15),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: msgController,
              decoration: const InputDecoration(
                labelText: 'send a message ...',
              ),
              enableSuggestions: true,
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            onPressed: submitMsg,
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
