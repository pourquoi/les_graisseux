import 'dart:async';

import 'package:app/controllers/account/chat.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/chat.dart';
import 'package:app/widgets/chat/chat_message_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ChatRoomPage extends StatefulWidget
{
  final ChatController controller = Get.find();
  final UserController userController = Get.find();

  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage>
{
  TextEditingController _messageController;
  Worker _scrollWorker;
  ScrollController _scrollController;

  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _messageController = TextEditingController();

    _scrollWorker = ever(widget.controller.roomMessages, (_) {
      scrollBotttom();
    });

    if (Get.parameters['chat'] != null) {
      widget.controller.loadRoom(Get.parameters['chat']);
    } else if (widget.controller.room.value.id != null) {
      widget.controller.loadRoom(widget.controller.room.value.uuid);
    }
  }

  void dispose() {
    _messageController.dispose();
    _scrollWorker.dispose();
    super.dispose();
  }

  void submit() async {
    await widget.controller.send(_messageController.text);
    _messageController.text = '';
    scrollBotttom();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildTitle(context)
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => 
          Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.controller.roomMessages.length,
                itemBuilder: (BuildContext context, int idx) {
                  ChatMessage msg = widget.controller.roomMessages[idx];
                  return ChatMessageCard(message: msg);
                }
              )
          )),
          buildInput(context)
        ],
      )       
    );
  }

  Widget buildInput(BuildContext context) {
    return Container(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
          children: [
            Obx(() {
              return Expanded(
                child: TextFormField(
                  maxLines: null,
                  onTap: () => scrollBotttom(),
                  enabled: !widget.controller.sending.value,
                  controller: _messageController,       
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Comment',
                  )
                ),
              );
            }),
            Obx(() {
              if (widget.controller.sending.value) {
                return CircularProgressIndicator();
              } else {
                return MaterialButton(
                  padding: EdgeInsets.all(16),
                  shape: CircleBorder(),
                  color: Colors.indigoAccent,
                  child: Icon(Icons.send), onPressed: () {
                  submit();
                });
              }
            })
          ]
        )
      ))
    );
  }

  Widget buildTitle(BuildContext context) {
    return Obx(() {
      if (widget.controller.loading.value) return Text('...');
      ChatRoom room = widget.controller.room.value;
      return Text(room.title??'');
    });
  }

  void scrollBotttom() {
    Timer(
      Duration(milliseconds: 300),
        () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
  }

}