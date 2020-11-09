import 'package:app/controllers/app.dart';
import 'package:app/pages/onboarding/step_account.dart';
import 'package:app/pages/onboarding/step_address.dart';
import 'package:app/pages/onboarding/step_completed.dart';
import 'package:app/pages/onboarding/step_description.dart';
import 'package:app/pages/onboarding/step_job_services.dart';
import 'package:app/pages/onboarding/step_job_vehicle.dart';
import 'package:app/pages/onboarding/step_mechanic_services.dart';
import 'package:app/pages/onboarding/step_profile.dart';
import 'package:app/pages/onboarding/step_username.dart';
import 'package:app/services/endpoints/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:app/controllers/onboarding.dart';

class OnboardingPage extends StatelessWidget {
  final UserService userService = Get.find();
  final AppController appController = Get.find();
  final OnboardingController controller = Get.put(OnboardingController());

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          bool changed = await controller.prev();
          return !changed;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Obx(() => Text(controller.title.value)),
            actions: [
              IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    appController.onboardingSkipped.value = true;
                    Get.back();
                  })
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(76, 61, 243, 1),
                  Color.fromRGBO(120, 58, 183, 1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Theme(
                data: ThemeData(buttonTheme: ButtonThemeData(buttonColor: Colors.yellow)),
                child: Stack(
                  children: <Widget>[
                    Line(),
                    Positioned.fill(
                      left: 32.0 + 8,
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 250),
                        child: Obx(() {
                          switch (controller.step.value) {
                            case OnboardingStep.Profile:
                              return StepProfile(key: Key('onboarding.profile'));
                            
                            case OnboardingStep.Account:
                              return StepAccount(key: Key('onboarding.account'));

                            case OnboardingStep.Username:
                              return StepUsername(key: Key('onboarding.username'));

                            case OnboardingStep.JobServices:
                              return StepJobServices(key: Key('onboarding.job_services'));
                            
                            case OnboardingStep.JobVehicle:
                              return StepJobVehicle(key: Key('onboarding.job_vehicle'));

                            case OnboardingStep.MechanicServices:
                              return StepMechanicServices(key: Key('onboarding.mechanic_services'));

                            case OnboardingStep.Address:
                              return StepAddress(key: Key('onboarding.address'));

                            case OnboardingStep.Description:
                              return StepDescription(key: Key('onboarding.description'));

                            case OnboardingStep.Completed:
                              return StepCompleted(key: Key('onboarding.completed'));

                            default:
                              return StepProfile(key: Key('onboarding.profile'));
                          }
                        }),
                      )
                    ),
                  ],
                ),
              ),
            )
          ),
        ));
  }
}

class Line extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 32.0 + 32 + 8,
      top: 40,
      bottom: 0,
      width: 1,
      child: Container(color: Colors.white.withOpacity(0.5)),
    );
  }
}
