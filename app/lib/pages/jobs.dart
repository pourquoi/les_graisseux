import 'package:app/controllers/jobs.dart';
import 'package:app/widgets/ui/drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobsPage extends StatelessWidget
{
  final JobsController controller = Get.put(JobsController());

  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('Jobs')),
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
                      },
                      child: Text('${idx}' +
                          (controller.items[idx].title ?? '')));
                },
              );
            }),
        )
      );
  }
}