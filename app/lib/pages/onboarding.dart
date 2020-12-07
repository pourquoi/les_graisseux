import 'package:app/controllers/app.dart';
import 'package:app/pages/onboarding/common.dart';
import 'package:app/pages/onboarding/step_account.dart';
import 'package:app/pages/onboarding/step_address.dart';
import 'package:app/pages/onboarding/step_completed.dart';
import 'package:app/pages/onboarding/step_description.dart';
import 'package:app/pages/onboarding/step_job_picture.dart';
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
import 'package:app/routes.dart' as routes;

const leftSpace = 32;

class OnboardingPage extends StatelessWidget {
  final UserService userService = Get.find();
  final AppController appController = Get.find();
  final OnboardingController controller = Get.put(OnboardingController());

  Widget build(BuildContext context) {
    return WillPopScope(
        // veto modal dismiss if there is previous steps
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
                  if (appController.routing.previous == '')
                    Get.offAllNamed(routes.home);
                  else 
                    Get.back();
              })
            ],
          ),
          body: SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                //color: Colors.black,
                image: DecorationImage(
                  colorFilter: ColorFilter.mode(Colors.amber, BlendMode.hue),
                  image: AssetImage('assets/images/garage-1.jpg'),
                  fit: BoxFit.cover
                )
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.9),
                  //gradient: RadialGradient(
                  //  colors: [Colors.white, Colors.amber]
                  //)
                ),
                child: Stack(
                children: <Widget>[
                  Line(),
                  Obx(() => AnimatedSwitcher(
                    duration: Duration(milliseconds: 400),
                    child: StepTitle(
                        key: Key(controller.step.value.toString()+'.title'),
                        title: controller.currentController.title
                      )
                    )
                  ),
                  Positioned.fill(
                    left: 32.0 + 8,
                    top: 40,
                    right: 8,
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints viewportConstraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: viewportConstraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
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

                                    case OnboardingStep.JobPicture:
                                      return StepJobPicture(key: Key('onboarding.job_picture'));

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
                            )
                          )
                        );
                      }
                    )
                  )
                ],
              )
            ),
          ),    
        ),
      )
    );
  }
}

class Line extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 32.0,
      top: 40,
      bottom: 0,
      width: 1,
      child: Container(color: Colors.white.withOpacity(0.5)),
    );
  }
}

class StepTitle extends StatelessWidget {
  final String title;
  const StepTitle({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 20),
      child: Text(title, style: TextStyle(color: Colors.white, fontSize: 14),)
    );
  }
}

