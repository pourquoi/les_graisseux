
import 'package:app/controllers/account/job.dart';
import 'package:app/controllers/onboarding.dart';
import 'package:app/models/service_tree.dart';
import 'package:app/pages/service_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepJobServices extends StatefulWidget {
  final OnboardingController controller = Get.find();
  final AccountJobController jobController = Get.find();

  StepJobServices({Key key}) : super(key: key);

  _StepJobServicesState createState() => _StepJobServicesState();
}

class _StepJobServicesState extends State<StepJobServices> {

  OnboardingJobServices get stepController => widget.controller.steps[OnboardingStep.JobServices];

  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        RaisedButton(
          onPressed: () async {
            ServiceTree service = await Get.to(ServicePicker());
            if (service != null) {
              stepController.addTask(service);
            }
          },
          child: Text('add service'),
        ),
        Obx(() {
          return Expanded(
            child: ListView.builder(
            itemCount: widget.jobController.job.value.tasks.length,
            itemBuilder: (_, idx) {
              return Row(
                children: <Widget>[
                  Text('${idx}' + (widget.jobController.job.value.tasks[idx].label ?? '')),
                  IconButton(
                    icon: Icon(Icons.close), 
                    onPressed: () => stepController.removeTask(widget.jobController.job.value.tasks[idx])
                  )
                ]
              );
            },
          ));
        }),
        RaisedButton(
            onPressed: () {
              widget.controller.next();
            },
            child: Text('next'))
      ],
    );
  }
}
