import 'package:app/controllers/job.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobPage extends StatelessWidget
{
  final JobController controller = Get.put(JobController());

  JobPage({Key key}) : super(key: key) {
    controller.load(int.parse(Get.parameters['job']));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(child:Obx(() {
          return Text(controller.job.value.title ?? '');
        }
        ))
      )
    );
  }
}