
import 'package:flutter/material.dart';
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
        SizedBox(height: 32),
        Spacer(),
        Padding(
          padding: EdgeInsets.only(left: 64, right: 32),
          child: RaisedButton(
            onPressed: () {
              Get.offAndToNamed(routes.account);
            }, 
            child: Text('Go to account')
          )
        ),
        Spacer()
      ],
    );
  }
}
