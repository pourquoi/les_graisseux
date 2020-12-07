import 'package:app/models/chat.dart';
import 'package:flutter/material.dart';

class ChatMessageCard extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageCard({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.user.user.username),
            Text(message.message),
            Text(message.date)
          ]
        )
      )
    );
  }
}