import 'package:app/controllers/account/chat.dart';
import 'package:app/controllers/mechanic.dart';
import 'package:app/controllers/user.dart';
import 'package:app/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:app/routes.dart' as routes;

class MechanicPage extends StatelessWidget
{
  final MechanicController controller = Get.put(MechanicController());
  final UserController userController = Get.find();
  final ChatController chatController = Get.find();

  MechanicPage({Key key}) : super(key:key) {
    print('MechanicPage.construct');
    int id;
    if (Get.parameters['mechanic'] != null) {
      id = int.parse(Get.parameters['mechanic']);
    } else if (controller.mechanic.value.id != null) {
      id = controller.mechanic.value.id;
    }
    controller.load(id);
  }

  Future chat() async {
    if (userController.loggedIn.value) {
      await chatController.initRoom(controller.mechanic.value.user);
      Get.toNamed(
        routes.chat_room.replaceFirst(':chat', chatController.room.value.uuid)
      );
    } else {
      Get.to(LoginPage(isModal: true));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildTitle(context),
        actions: [
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: Obx(() => controller.loading.value || controller.mechanic.value.id == null ?
          Center(child: CircularProgressIndicator()) :
          Stack(
            children: <Widget>[
              buildHeader(context),
              buildBody(context),
              buildChat(context)
            ]
          )
        )
      )
    );
  }

  Widget buildTitle(BuildContext context) {
    return Obx(() => controller.mechanic.value.id != null ? 
      Text(controller.mechanic.value.user.username ?? '') : 
      Text('...')
    );
  }

  Widget buildHeader(BuildContext context) {
    return SizedBox.shrink();
  }

  Widget buildBody(BuildContext context) {
    return SizedBox.shrink();
  }

  Widget buildChat(BuildContext context) {
    return OutlineButton(
      onPressed: () async => await chat(),
      child: Row(
        children: [
          Text('Chat'),
          Obx(() => chatController.loading.value ? CircularProgressIndicator() : Icon(FontAwesomeIcons.comment))
        ],
      )
    );
  }
}