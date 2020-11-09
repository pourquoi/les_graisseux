
import 'package:app/controllers/onboarding.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/onboarding/common.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepProfile extends StatefulWidget {
  final OnboardingController controller = Get.find();

  StepProfile({Key key}) : super(key: key);

  _StepProfileState createState() => _StepProfileState();
}

class _StepProfileState extends State<StepProfile> with SingleTickerProviderStateMixin
{
  OnboardingProfile get stepController => widget.controller.steps[OnboardingStep.Profile];

  List<GlobalKey<ItemFaderState>> keys;

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
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 32),
        Spacer(),
        ItemFader(
          itemCount: 2,
          itemIndex: 0,
          key: keys[0],
          child: RaisedButton(
            onPressed: () {
              stepController.selectProfile(ProfileType.Customer);
              submit();
            },
            child: Text('onboarding.profile.choice_customer'.tr)
          )
        ),
        ItemFader(
          key: keys[1],
          itemCount: 2,
          itemIndex: 1,
          child: RaisedButton(
            onPressed: () {
              stepController.selectProfile(ProfileType.Mechanic);
              submit();
            },
            child: Text('onboarding.profile.choice_mechanic'.tr)
          )
        ),
        Spacer()
      ],
    );
  }
}
