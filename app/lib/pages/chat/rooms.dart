import 'package:app/controllers/account/chat.dart';
import 'package:app/controllers/user.dart';
import 'package:app/widgets/ui/drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/routes.dart' as routes;

class ChatRoomsPage extends StatefulWidget
{
  final UserController userController = Get.find();
  final ChatController controller = Get.find();
  _ChatRoomsPageState createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage>
{
  void initState() {
    super.initState();  
    widget.controller.loadRooms();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
              floating: true,
              snap: false,
              pinned: true,
              expandedHeight: 150.0,
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    ]
                  )
                ),
                stretchModes: <StretchMode>[
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ],
                title: Text('Messages')
              ),
            ),
            Obx( () =>
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, idx) {
                      if (idx < widget.controller.rooms.length)
                        return buildRow(context, idx);
                      else if (idx == widget.controller.rooms.length) {
                        if (widget.controller.roomsPagination.value.next != null) {
                          return CircularProgressIndicator();
                        } else {
                          return SizedBox.shrink();
                        }
                      } else {
                        return SizedBox.shrink();
                      }
                  },
                  childCount: widget.controller.rooms.length + 1
                )   
              ),
            )
        ]
      )
    );
  }

  Widget buildRow(BuildContext context, int idx) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(routes.chat_room.replaceFirst(':chat', widget.controller.rooms[idx].uuid));
      },
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Text(widget.controller.rooms[idx].getInterlocutor(widget.userController.user.value.id).user.username),
            Obx(() {
              if (widget.controller.rooms[idx].application != null) {
                return Text(widget.controller.rooms[idx].application.job.title);
              } else {
                return SizedBox.shrink();
              }
            }),
            Obx(() {
              if (widget.controller.rooms[idx].lastMessage != null) {
                return Text(widget.controller.rooms[idx].lastMessage.message);
              } else {
                return SizedBox.shrink();
              }
            })
          ]
        )
      )
    );
  }
}