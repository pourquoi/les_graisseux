
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

  Future submit() async {
    for (GlobalKey<ItemFaderState> key in keys) {
      if (key.currentState != null) {
        await key.currentState.hide();
      }
    }
    widget.controller.next();
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        ItemFader(
          itemCount: 2,
          itemIndex: 0,
          key: keys[0],
          child: Obx(() => RadioListTile<ProfileType>(
            title: Text('onboarding.profile.choice_customer'.tr),
            value: ProfileType.Customer,
            groupValue: widget.controller.profileType.value,
            onChanged: (val) {
              stepController.selectProfile(ProfileType.Customer);
              submit();
            }
          ))
        ),
        ItemFader(
          key: keys[1],
          itemCount: 2,
          itemIndex: 1,
          child: Obx(() => RadioListTile<ProfileType>(
            title: Text('onboarding.profile.choice_mechanic'.tr),
            value: ProfileType.Mechanic,
            groupValue: widget.controller.profileType.value,
            onChanged: (val) async {
              stepController.selectProfile(ProfileType.Mechanic);
              await submit();
            }
          ))
        ),
        Spacer()
      ],
    );
  }
}
