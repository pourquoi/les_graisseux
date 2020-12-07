import 'package:app/controllers/account/chat.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/chat.dart';
import 'package:app/widgets/chat/room_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
              //expandedHeight: 150.0,
              actions: <Widget>[
                OutlineButton(
                  textColor: Colors.black,
                  onPressed: () {
                  },
                  child: Row(
                    children: [
                      Obx(() => widget.controller.roomsParams.value.sort != null ?
                        Text(('sorts.'+widget.controller.roomsParams.value.sort).tr) : 
                        Text('sort_by'.tr)
                      ),
                      Icon(FontAwesomeIcons.caretDown)
                    ],
                  )
                )
              ],
              title: Text('pages.messages.title'.tr),
            ),
            Obx( () =>
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, idx) {
                      if (idx < widget.controller.rooms.length) {
                        ChatRoom room = widget.controller.rooms[idx];
                        return ChatRoomCard(
                          room: room,
                          user: widget.userController.user.value,
                          onTap: () {
                            Get.toNamed(routes.chat_room.replaceFirst(':chat', room.uuid));
                          }
                        );
                      } else if (idx == widget.controller.rooms.length) {
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
}