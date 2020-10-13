import 'package:app/controllers/mechanic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MechanicPage extends StatelessWidget
{
  final MechanicController controller = Get.put(MechanicController());

  Widget build(BuildContext context) {
    int id = int.parse(Get.parameters['mechanic']);

    controller.load(id);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Obx(() {
            if( controller.current.value.id != null ) {
              return Text(controller.current.value.user.email ?? '?');
            } else {
              return CircularProgressIndicator();
            }
          })
        )
      )
    );
  }
}