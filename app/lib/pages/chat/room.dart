import 'dart:async';

import 'package:app/controllers/account/chat.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/chat.dart';
import 'package:app/widgets/ui/drawer.dart';
import 'package:flutter/material.dart';
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
  ScrollController _scrollController = ScrollController();

  void initState() {
    super.initState();
    _messageController = TextEditingController();

    bool isNew = false;
    try {
      isNew = Get.arguments['new'];
    } catch(error) {}

    if (!isNew) {
      widget.controller.loadRoom(Get.parameters['chat']);
    }
  }

  void submit() async {
    await widget.controller.send(_messageController.text);
    _messageController.text = '';
    scrollBotttom();
  }

  Widget buildRow(BuildContext context, int idx) {
    print('${widget.controller.roomMessages[idx].message} ${idx}');
    return GestureDetector(
      onTap: () {
        
      },
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Row(
              children: [
                Text('${widget.controller.roomMessages[idx].user.user.username} ${widget.controller.roomMessages[idx].user.id}'),
                Text(widget.controller.roomMessages[idx].date)
              ]
            ),
            Text('${widget.controller.roomMessages[idx].message} ${idx}')
          ]
        )
      )
    );
  }

  void scrollBotttom() {
    Timer(
      Duration(milliseconds: 300),
        () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          ChatUser interlocutor;
          if (widget.userController.user.value.id != null) {
            interlocutor = widget.controller.room.value.getInterlocutor(widget.userController.user.value.id);
          }
          if (interlocutor != null) {
            return Text(interlocutor.user.username ?? '-');
          } else {
            return Text('...');
          }
        })
      ),
      drawer: AppDrawer(),
      body: 
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => 
            Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: widget.controller.roomMessages.length,
                  itemBuilder: (BuildContext context, int idx) {
                    return buildRow(context, idx);
                  }
                )
            )),
            Container(
              height: 80,
              child:
              Row(
                children: [
                  Obx(() {
                    return Expanded(
                      child: TextFormField(
                        onTap: () => scrollBotttom(),
                        enabled: !widget.controller.sending.value,
                        controller: _messageController,       
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          icon: Icon(Icons.lock),
                          hintText: 'message',
                        )
                      ),
                    );
                  }),
                  Obx(() {
                    if (widget.controller.sending.value) {
                      return CircularProgressIndicator();
                    } else {
                      return IconButton(icon: Icon(Icons.send), onPressed: () {
                        submit();
                      });
                    }
                  })
                ]
              )
            )

          ],
        )       
      );
  }
}