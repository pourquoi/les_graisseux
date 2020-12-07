
import 'package:app/pages/account/profile.dart';
import 'package:app/pages/onboarding/common.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/models/mechanic.dart';
import 'package:app/controllers/onboarding.dart';
import 'package:app/controllers/account/mechanic.dart';

class StepMechanicServices extends StatefulWidget {
  final OnboardingController controller = Get.find();
  final AccountMechanicController mechanicController = Get.find();

  StepMechanicServices({Key key}) : super(key: key);

  _StepMechanicServicesState createState() => _StepMechanicServicesState();
}

class _StepMechanicServicesState extends State<StepMechanicServices> {
  List<GlobalKey<ItemFaderState>> keys;

  OnboardingMechanicServices get stepController => widget.controller.steps[OnboardingStep.MechanicServices];

  void initState() {
    super.initState();
    keys = List.generate(2, (_) => GlobalKey<ItemFaderState>());
  }

  void submit() async {
    for (GlobalKey<ItemFaderState> key in keys) {
      if (key.currentState != null) {
        await key.currentState.hide();
      }
    }
    widget.controller.next();
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Spacer(),

        Obx(() =>  widget.mechanicController.mechanic.value.services.length > 0 ?
          ItemFader(
            itemCount: 2,
            itemIndex: 0,
            key: keys[0],
            child: MechanicServicesForm(controller: widget.mechanicController)
          )
          :
          SizedBox.shrink()
        ),

        OutlineButton(
          key: keys[0],
          onPressed: () async {
            widget.mechanicController.mechanic.value.services.add(MechanicSkill());
            widget.mechanicController.mechanic.refresh();
          },
          child: Obx(() => widget.mechanicController.mechanic.value.services.length == 0 ?
          Text('Pick a service') : Text('Add a service'))
        ),

        Spacer(),

        Align(
          alignment: Alignment.centerRight,
          child: RaisedButton(
            onPressed: () => submit(),
            child: Obx(() => widget.mechanicController.mechanic.value.services.length == 0 ?
              Text('Skip') : Icon(Icons.navigate_next_rounded))
          ),
        )
      ]
    );
  }
}
