import 'package:app/controllers/job.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/job_application.dart';
import 'package:app/models/user.dart';
import 'package:app/services/endpoints/job.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/routes.dart' as routes;

class JobPage extends StatelessWidget
{
  final UserController userController = Get.find();
  final JobApplicationService jobApplicationService = Get.find();
  final JobController controller = Get.put(JobController());

  JobPage({Key key}) : super(key: key) {
    controller.load(int.parse(Get.parameters['job']));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => controller.loading.value ? Text('...') : Text(controller.job.value.title)),
        actions: [
          Obx(() {
            if (userController.status.value == UserStatus.loggedin && userController.user.value.mechanic != null) {
              if (controller.job.value.application != null) {
                return IconButton(
                  onPressed: () async {
                    JobApplication app = await jobApplicationService.get(controller.job.value.application.id);
                    if (app.chat != null)
                      Get.toNamed(routes.chat_room.replaceFirst(':chat', app.chat.uuid));
                  },
                  icon: Icon(Icons.apps_outlined)
                );
              } else {
                return IconButton(
                  onPressed: () async {
                    JobApplication app = await controller.apply();
                    if (app.chat != null) {
                      Get.toNamed(routes.chat_room.replaceFirst(':chat', app.chat.uuid));
                    }
                  },
                  icon: Icon(Icons.message)
                );
              }
            } else {
              return IconButton(
                onPressed: () {
                  Get.toNamed(routes.onboarding, arguments: {'type': ProfileType.Mechanic});
                },
                icon: Icon(Icons.message)
              );
            }
          })
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Center(child:Obx(() {
              return Text(controller.job.value.title ?? '');
            })),
          ],
        )
      )
    );
  }
}