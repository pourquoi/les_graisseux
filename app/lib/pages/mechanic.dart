import 'package:app/controllers/account/chat.dart';
import 'package:app/controllers/mechanic.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/chat.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/routes.dart' as routes;

class MechanicPage extends StatefulWidget
{
  final MechanicController controller = Get.put(MechanicController());
  final UserController userController = Get.find();
  final ChatController chatController = Get.find();

  _MechanicPageState createState() => _MechanicPageState();
}

class _MechanicPageState extends State<MechanicPage>
{
  void initState() {
    super.initState();
    print('_MechanicPageState.initState');
    int id = int.parse(Get.parameters['mechanic']);
    widget.controller.load(id);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => widget.controller.current.value.id != null ? Text(widget.controller.current.value.user.username ?? '') : Text('...')),
        actions: [
          Obx(() {
            if (widget.userController.status.value == UserStatus.loggedin) {
              return IconButton(
                onPressed: () async {
                  await widget.chatController.initRoom(widget.controller.current.value.user);
                  Get.toNamed(routes.chat_room.replaceFirst(':chat', widget.chatController.room.value.uuid), arguments: {'new': true});
                },
                icon: Icon(Icons.message)
              );
            } else {
              return IconButton(
                onPressed: () {
                  Get.toNamed(routes.onboarding, arguments: {'type': ProfileType.Customer});
                },
                icon: Icon(Icons.message)
              );
            }
          })
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: Obx(() => widget.controller.loading.value ?
          Center(child: CircularProgressIndicator()) :
          Stack(
            children: <Widget>[
              Center(
                child: Text(widget.controller.current.value.user.username ?? '?')  
              ),
            ]
          )
        )
      )
    );
  }
}