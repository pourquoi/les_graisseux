import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/routes.dart' as routes;
import 'package:app/controllers/mechanics.dart';
import 'package:app/widgets/ui/drawer.dart';

class MechanicsPage extends StatelessWidget
{
  final MechanicsController controller = Get.put(MechanicsController());

  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('Mechanics')),
        drawer: AppDrawer(),
        body: SafeArea(
          child:
            Obx(() {
              return ListView.builder(
                itemCount: controller.items.length,
                itemBuilder: (_, idx) {
                  return GestureDetector(
                      onTap: () {
                        print(controller.items[idx]);
                        Get.toNamed(routes.mechanic.replaceFirst(':mechanic', controller.items[idx].id.toString()));
                      },
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('${idx}' + (controller.items[idx].user.username ?? '-'), style: TextStyle(fontSize: 20))
                      )
                  );
                },
              );
            }),
        )
      );
  }
}