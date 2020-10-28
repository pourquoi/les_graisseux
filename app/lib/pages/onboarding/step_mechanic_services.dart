
import 'package:app/pages/account/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/widgets/ui/stars.dart';

import 'package:app/models/mechanic.dart';
import 'package:app/models/vehicle_tree.dart';
import 'package:app/models/service_tree.dart';

import 'package:app/controllers/onboarding.dart';
import 'package:app/controllers/account/mechanic.dart';

import 'package:app/pages/service_picker.dart';
import 'package:app/pages/vehicle_picker.dart';

class StepMechanicServices extends StatefulWidget {
  final OnboardingController controller = Get.find();
  final AccountMechanicController mechanicController = Get.find();

  StepMechanicServices({Key key}) : super(key: key);

  _StepMechanicServicesState createState() => _StepMechanicServicesState();
}

class _StepMechanicServicesState extends State<StepMechanicServices> {

  final _formKey = GlobalKey<FormState>();

  OnboardingMechanicServices get stepController => widget.controller.steps[OnboardingStep.MechanicServices];

  void initState() {
    super.initState();
  }

  void submit() async {
    //if (_formKey.currentState.validate()) {
      await widget.controller.next();
    //}
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SingleChildScrollView(
          child: MechanicServicesForm(controller: widget.mechanicController)
        ),

        Obx(() {
          if (widget.mechanicController.mechanic.value.services.length < 100) {
            return RaisedButton(
              onPressed: () {
                widget.mechanicController.mechanic.value.services.add(MechanicSkill());
                widget.mechanicController.mechanic.refresh();
              },
              child: Text('add')
            );
          } else {
            return SizedBox.shrink();
          }
        }),

        RaisedButton(
          onPressed: () => submit(),
          child: Text('next')
        )
      ]
    );
  }
}
