import 'package:app/controllers/account/chat.dart';
import 'package:app/widgets/ui/drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/routes.dart' as routes;

class ChatRoomsPage extends StatefulWidget
{
  final ChatController controller = Get.find();
  _ChatRoomsPageState createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage>
{
  void initState() {
    super.initState();  
    widget.controller.loadRooms();
  }

  Widget buildRow(BuildContext context, int idx) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(routes.chat_room.replaceFirst(':chat', widget.controller.rooms[idx].uuid));
      },
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text('${widget.controller.rooms[idx].uuid} ${idx}')
      )
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
              floating: true,
              snap: false,
              actions: <Widget>[
                IconButton(icon: Icon(Icons.settings), onPressed: null)
              ],
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
                title: Text('My Discussions')
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
//                            widget.controller.more();
                            return CircularProgressIndicator();
                          } else {
                            return Text('1');
                          }
                        } else {
                          return Text('2');
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