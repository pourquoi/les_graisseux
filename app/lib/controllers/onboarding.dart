import 'dart:convert';
import 'package:app/models/vehicle_tree.dart';
import 'package:equatable/equatable.dart';

import 'package:app/models/service_tree.dart';
import 'package:app/services/user.dart';
import 'package:get/state_manager.dart';

import 'package:app/controllers/app.dart';
import 'package:app/models/user.dart';

enum OnboardingStep { Profile, Account, Services, Vehicle, Completed }

class OnboardingStepController extends Equatable {
  final OnboardingStep step;
  final OnboardingStep next;
  final OnboardingStep prev;

  OnboardingStepController(this.step, {this.next, this.prev});

  @override
  List<Object> get props => [step];
}

class OnboardingController extends GetxController {
  OnboardingController() {}

  void onInit() {
    appController = Get.find<AppController>();
    userService = Get.find<UserService>();

    _buildSteps();
  }

  AppController appController;
  UserService userService;

  final user = User().obs;

  final vehicle = VehicleTree().obs;

  final RxList<ServiceTree> services = List<ServiceTree>().obs;

  final profileType = ProfileType.Undefined.obs;

  final step = OnboardingStep.Profile.obs;

  final loading = false.obs;

  Map<OnboardingStep, OnboardingStepController> steps;

  void _buildSteps() {
    if (profileType.value == ProfileType.Undefined) {
      steps = {
        OnboardingStep.Profile:
            OnboardingStepController(OnboardingStep.Profile),
      };
    } else {
      if (profileType.value == ProfileType.Mechanic) {
        steps = {
          OnboardingStep.Profile: OnboardingStepController(
              OnboardingStep.Profile,
              next: OnboardingStep.Services),
          OnboardingStep.Services: OnboardingStepController(
              OnboardingStep.Services,
              next: OnboardingStep.Vehicle,
              prev: OnboardingStep.Profile),
          OnboardingStep.Vehicle: OnboardingStepController(
              OnboardingStep.Vehicle,
              next: OnboardingStep.Account,
              prev: OnboardingStep.Services),
          OnboardingStep.Account: OnboardingStepController(
              OnboardingStep.Account,
              next: OnboardingStep.Completed,
              prev: OnboardingStep.Vehicle),
          OnboardingStep.Completed:
              OnboardingStepController(OnboardingStep.Completed),
        };
      } else if (profileType.value == ProfileType.Customer) {
        steps = {
          OnboardingStep.Profile: OnboardingStepController(
              OnboardingStep.Profile,
              next: OnboardingStep.Services),
          OnboardingStep.Services: OnboardingStepController(
              OnboardingStep.Services,
              next: OnboardingStep.Vehicle,
              prev: OnboardingStep.Profile),
          OnboardingStep.Vehicle: OnboardingStepController(
              OnboardingStep.Vehicle,
              next: OnboardingStep.Account,
              prev: OnboardingStep.Services),
          OnboardingStep.Account: OnboardingStepController(
              OnboardingStep.Account,
              next: OnboardingStep.Completed,
              prev: OnboardingStep.Vehicle),
          OnboardingStep.Completed:
              OnboardingStepController(OnboardingStep.Completed),
        };
      }
    }
  }

  Future<bool> next() {
    _buildSteps();

    OnboardingStep last = step.value;

    if (steps.containsKey(last) && steps[last].next != null) {
      step.value = steps[last].next;
    }

    return Future.value(last != step.value);
  }

  Future<bool> prev() {
    _buildSteps();

    OnboardingStep last = step.value;

    if (steps.containsKey(last) && steps[last].prev != null) {
      step.value = steps[last].prev;
    }

    return Future.value(last != step.value);
  }

  void selectProfile(ProfileType profile) {
    profileType.value = profile;
    next();
  }

  void register({String email, String password}) {
    user.update((v) {
      v.email = email;
      v.password = password;
    });

    loading.value = true;
    userService
        .register(email: user.value.email, password: user.value.password)
        .then((_) {
      loading.value = false;
      next();
    }).catchError((error) {
      loading.value = false;
    });
  }

  void selectVehicle(VehicleTree vehicle) {}
}
