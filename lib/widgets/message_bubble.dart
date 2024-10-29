import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble.first(
      {required this.text,
      required this.isMe,
      this.imageUrl,
      this.userName,
      super.key})
      : isFirstInSequence = true;
  const MessageBubble.next({required this.text, required this.isMe, super.key})
      : imageUrl = null,
        userName = null,
        isFirstInSequence = false;
  final bool isFirstInSequence;
  final String text;
  final bool isMe;
  final String? imageUrl;
  final String? userName;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        if (isFirstInSequence)
          Positioned(
            top: 15,
            right: isMe ? 0 : null,
            child: CircleAvatar(
              backgroundImage: NetworkImage(imageUrl!),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 23,
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 46),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (userName != null)
                    const SizedBox(
                      height: 20,
                    ),
                  if (isFirstInSequence)
                    Padding(
                      padding: const EdgeInsets.only(right: 14, left: 14),
                      child: Text(
                        userName!,
                        style: const TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 10),
                    margin: const EdgeInsets.only(top: 5, right: 5, left: 5),
                    constraints: const BoxConstraints(maxWidth: 200),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.grey[300]
                          : theme.colorScheme.secondary.withAlpha(200),
                      borderRadius: BorderRadius.only(
                        topRight: userName != null && isMe
                            ? Radius.zero
                            : const Radius.circular(10),
                        topLeft: userName != null && !isMe
                            ? Radius.zero
                            : const Radius.circular(10),
                        bottomLeft: const Radius.circular(10),
                        bottomRight: const Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                          color: isMe
                              ? Colors.black87
                              : theme.colorScheme.onSecondary,
                          height: 1.3),
                      softWrap: true,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
