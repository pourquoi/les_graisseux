import 'package:app/models/chat.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';

class ChatRoomCard extends StatelessWidget {
  final Function onTap;
  final ChatRoom room;
  final User user;
  const ChatRoomCard({Key key, @required this.room, this.onTap, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Container(
            height: 50,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(child: Text(room.title??'')),
                    (
                      room.lastMessage != null ?
                      Text(room.lastMessage.message) :
                      SizedBox.shrink()
                    )
                  ]
                )
              ]
            )
          )
        )
      )
    );
  }
}