
import 'package:app/controllers/onboarding.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepProfile extends StatelessWidget {
  final OnboardingController controller = Get.find();

  StepProfile({Key key}) : super(key: key);

  OnboardingProfile get stepController => controller.steps[OnboardingStep.Profile];

  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RaisedButton(
            onPressed: () {
              stepController.selectProfile(ProfileType.Customer);
            },
            child: Text('onboarding.profile.choice_customer'.tr)),
        RaisedButton(
            onPressed: () {
              stepController.selectProfile(ProfileType.Mechanic);
            },
            child: Text('onboarding.profile.choice_mechanic'.tr))
      ],
    );
  }
}
