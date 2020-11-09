
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
        SizedBox(height: 32),

        Obx(() => widget.mechanicController.mechanic.value.services.length == 0 ?
        Spacer() : SizedBox.shrink()),

        Obx(() => widget.mechanicController.mechanic.value.services.length > 0 ?
          Expanded(child:Padding(
            padding: EdgeInsets.only(left: 32, right: 0),
            child: SingleChildScrollView(
              child: MechanicServicesForm(controller: widget.mechanicController)
            )
          )) : 
          SizedBox.shrink()
        ),

        Padding(
          padding: EdgeInsets.only(left: 32, right: 8),
          child: 
          Obx(() => widget.mechanicController.mechanic.value.services.length == 0 ? 
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: RaisedButton(
                    key: keys[0],
                    onPressed: () async {
                      widget.mechanicController.mechanic.value.services.add(MechanicSkill());
                      widget.mechanicController.mechanic.refresh();
                    },
                    child: Text('Add a service')
                  )
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => submit(),
                    child: Text('skip')
                  ),
                )
              ]
            ) :
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: RaisedButton(
                    onPressed: () async {
                      widget.mechanicController.mechanic.value.services.add(MechanicSkill());
                      widget.mechanicController.mechanic.refresh();
                    },
                    child: Text('Add more')
                  )
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: RaisedButton(
                    color: Colors.greenAccent,
                    onPressed: () => submit(),
                    child: Text('Next')
                  ),
                )
              ]
            ),
          )
        ),

        Obx(() => widget.mechanicController.mechanic.value.services.length == 0 ?
        Spacer() : SizedBox.shrink()),

      ]
    );
  }
}
