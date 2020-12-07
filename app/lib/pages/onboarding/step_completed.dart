
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:app/routes.dart' as routes;
import 'package:app/controllers/onboarding.dart';

class StepCompleted extends StatelessWidget {
  final OnboardingController controller = Get.find();

  OnboardingCompleted get stepCompleted => controller.currentController;

  StepCompleted({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        Obx(() => controller.profileType.value == ProfileType.Mechanic ?
          Text('Your mechanic profile has been created !') :
          Text('Your job has been published !')
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              color: Colors.greenAccent,
              onPressed: () {
                Get.offAndToNamed(routes.account);
              }, 
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.undo),
                  SizedBox(width: 5),
                  Text('Back to Home')
                ]
              )
            )
          ]
        ),
        Spacer()
      ],
    );
  }
}
