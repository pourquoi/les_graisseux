import 'package:get/get.dart';

import 'package:app/models/user.dart';
import 'package:app/models/address.dart';
import 'package:app/models/user_vehicle.dart';
import 'package:app/models/job.dart';
import 'package:app/models/vehicle_tree.dart';
import 'package:app/models/service_tree.dart';

import 'package:app/controllers/user.dart';
import 'package:app/controllers/app.dart';
import 'package:app/controllers/account/job.dart';
import 'package:app/controllers/account/mechanic.dart';

enum OnboardingStep { 
  Profile, 
  Account, 
  Username,
  JobServices, 
  JobVehicle, 
  JobPicture,
  MechanicServices, 
  Address, 
  Description, 
  Completed,
}

abstract class OnboardingStepController {
  OnboardingStep next();
  OnboardingStep prev();

  bool get disabled => false;

  String get title => '';
}

class OnboardingProfile with OnboardingStepController {
  ProfileType initialProfile;
  OnboardingController _controller;

  OnboardingProfile(this._controller, {this.initialProfile});

  bool get disabled => initialProfile == ProfileType.Mechanic || initialProfile == ProfileType.Customer;
  
  String get title => 'Profile'.tr;

  OnboardingStep next() {
    return OnboardingStep.Account;
  }

  OnboardingStep prev() {
    return null;
  }

  void selectProfile(ProfileType type) {
    _controller.profileType.value = type;
  }
}

class OnboardingAccount with OnboardingStepController {
  OnboardingController _controller;

  OnboardingAccount(this._controller);

  bool get disabled => _controller.userController.loggedIn.value;

  String get title => 'Account'.tr;

  OnboardingStep next() {
    return OnboardingStep.Username;
  }

  OnboardingStep prev() {
    return OnboardingStep.Profile;
  }

  Future register({String email, String password}) {
    _controller.loading.value = true;
    
    return _controller.userController
          .register(email: email, password: password)
          .then((_) {
            _controller.loading.value = false;
            _controller.next();
          }).catchError((error) {
            _controller.loading.value = false;
          });
  }
}

class OnboardingUsername with OnboardingStepController {
  OnboardingController _controller;

  OnboardingUsername(this._controller);

  bool get disabled {
    return _controller.userController.user.value.username != null && _controller.userController.user.value.username != '';
  }

  String get title => 'Username'.tr;

  OnboardingStep next() {
    if (_controller.profileType.value == ProfileType.Customer) {
      return OnboardingStep.JobServices;
    } else {
      return OnboardingStep.MechanicServices;
    }
  }

  OnboardingStep prev() {
    return OnboardingStep.Account;
  }
}

class OnboardingJobServices with OnboardingStepController {
  OnboardingController _controller;

  OnboardingJobServices(this._controller);

  String get title => 'onboarding.job_services.title'.tr;

  OnboardingStep next() {
    if (_controller.jobController.job.value.tasks.isNotEmpty)
      return OnboardingStep.JobVehicle;
    else
      return null;
  }

  OnboardingStep prev() {
    if (_controller.userController.loggedIn.value) {
      return null;
    } else {
      return OnboardingStep.Username;
    }
  }

  void addTask(ServiceTree task) {
    _controller.jobController.job.value.tasks.add(task);
    _controller.jobController.job.refresh();
  }

  void removeTask(ServiceTree task) {
    _controller.jobController.job.value.removeTask(task);
    _controller.jobController.job.refresh();
  }
}

class OnboardingJobVehicle with OnboardingStepController {
  OnboardingController _controller;

  OnboardingJobVehicle(this._controller);

  String get title => 'onboarding.job_vehicle.title'.tr;

  OnboardingStep next() {
    return OnboardingStep.JobPicture;
  }

  OnboardingStep prev() {
    return OnboardingStep.JobServices;
  }

  void setVehicle(VehicleTree vehicle) {
    Job job = _controller.jobController.job.value;
    if (vehicle == null) {
      job.vehicle = null;
    } else {
      if (job.vehicle == null) {
        job.vehicle = new UserVehicle();
      }

      job.vehicle.type = vehicle;
      job.vehicle.user = _controller.userController.user.value;
    }
    _controller.jobController.job.refresh();
  }
}

class OnboardingJobPicture with OnboardingStepController {
  OnboardingController _controller;

  OnboardingJobPicture(this._controller);

  String get title => 'onboarding.job_picture.title'.tr;

  OnboardingStep next() {
    return OnboardingStep.Address;
  }

  OnboardingStep prev() {
    return OnboardingStep.JobVehicle;
  }
}

class OnboardingMechanicServices with OnboardingStepController {
  OnboardingController _controller;

  OnboardingMechanicServices(this._controller);

  String get title => 'onboarding.mechanic_services.title'.tr;

  OnboardingStep next() {
    return OnboardingStep.Address;
  }

  OnboardingStep prev() {
    return OnboardingStep.Username;
  }
}

class OnboardingAddress with OnboardingStepController {
  OnboardingController _controller;

  OnboardingAddress(this._controller);

  String get title => _controller.profileType.value == ProfileType.Mechanic ?
  'onboarding.mechanic_address.title'.tr : 'onboarding.job_address.title'.tr;

  OnboardingStep next() {
    return OnboardingStep.Description;
  }

  OnboardingStep prev() {
    if (_controller.profileType.value == ProfileType.Customer) {
      return OnboardingStep.JobVehicle;
    } else {
      return OnboardingStep.MechanicServices;
    }
  }

  Future<void> setAddress(Address address) async {
    if (_controller.profileType.value == ProfileType.Customer) {
      _controller.jobController.job.value.address = address;
      _controller.jobController.job.refresh();
    }

    await _controller.userController.editAddress(address);
  }
}

class OnboardingDescription with OnboardingStepController {
  OnboardingController _controller;

  OnboardingDescription(this._controller);

  String get title => _controller.profileType.value == ProfileType.Mechanic ?
  'onboarding.mechanic_description.title'.tr : 'onboarding.job_description.title'.tr;

  OnboardingStep next() {
    return OnboardingStep.Completed;
  }

  OnboardingStep prev() {
    return OnboardingStep.Address;
  }
}

class OnboardingCompleted with OnboardingStepController {
  OnboardingController _controller;

  OnboardingCompleted(this._controller);

  OnboardingStep next() {
    return null;
  }

  OnboardingStep prev() {
    return null;
  }
}

class OnboardingController extends GetxController {
  final profileType = ProfileType.Undefined.obs;
  final step = OnboardingStep.Profile.obs;
  final loading = false.obs;
  final title = ''.obs;

  Map<OnboardingStep, OnboardingStepController> steps;

  AppController appController;
  UserController userController;
  AccountJobController jobController;
  AccountMechanicController mechanicController;

  OnboardingController();

  void onInit() {
    print('OnboardingController.onInit');

    appController = Get.find<AppController>();
    userController = Get.find<UserController>();
    jobController = Get.find<AccountJobController>();
    mechanicController = Get.find<AccountMechanicController>();

    jobController.initJob();

    try {
      profileType.value = Get.arguments['type'];
    } catch(error) {}

    steps = {
      OnboardingStep.Profile: OnboardingProfile(this, initialProfile: profileType.value),
      OnboardingStep.Account: OnboardingAccount(this),
      OnboardingStep.Username: OnboardingUsername(this),
      OnboardingStep.JobServices: OnboardingJobServices(this),
      OnboardingStep.JobVehicle: OnboardingJobVehicle(this),
      OnboardingStep.JobPicture: OnboardingJobPicture(this),
      OnboardingStep.MechanicServices: OnboardingMechanicServices(this),
      OnboardingStep.Address: OnboardingAddress(this),
      OnboardingStep.Description: OnboardingDescription(this),
      OnboardingStep.Completed: OnboardingCompleted(this)
    };

    if (profileType.value != ProfileType.Customer && profileType.value != ProfileType.Mechanic) {
      if (userController.user.value.mechanic == null && userController.user.value.customer != null) {
        profileType.value = ProfileType.Mechanic;
      } else if (userController.user.value.mechanic != null && userController.user.value.customer == null) {
        profileType.value = ProfileType.Customer;
      }
    }

    if (profileType.value != ProfileType.Customer && profileType.value != ProfileType.Mechanic) {
      step.value = OnboardingStep.Profile;
      title.value = 'onboarding.title.register'.tr;
    } else {
      if (profileType.value == ProfileType.Customer) {
        step.value = OnboardingStep.JobServices;
        title.value = 'onboarding.title.job'.tr;
      } else {
        step.value = OnboardingStep.MechanicServices;
        title.value = 'onboarding.title.mechanic'.tr;
      }
    }
  }

  OnboardingStepController get currentController => steps[step];

  Future<bool> next() async {
    OnboardingStep _currentStep = step.value;

    while( _currentStep != null ) {
      OnboardingStep next = steps[_currentStep].next();
      if (next != null) {
        if (steps[next].disabled) {
          _currentStep = next;
          continue;
        } else {
          step.value = next;
          return true;
        }
      } else {
        break;
      }
    }

    return false;
  }

  Future<bool> prev() async {
    OnboardingStep _currentStep = step.value;

    while (_currentStep != null) {
      OnboardingStep prev = steps[_currentStep].prev();
      if (prev != null) {
        if (steps[prev].disabled) {
          _currentStep = prev;
          continue;
        } else {
          step.value = prev;
          return true;
        }
      } else {
        break;
      }
    }

    return false;
  }

  void submit() async {
    if (profileType.value == ProfileType.Customer) {
      loading.value = true;
      try {
        await jobController.submit();
        appController.profileType.value = ProfileType.Customer;
        userController.user.refresh();
        next();
      } catch(error) {
        throw error;
      }
      loading.value = false;
    } else {
      loading.value = true;
      try {
        await mechanicController.submit();
        appController.profileType.value = ProfileType.Mechanic;
        userController.user.refresh();
        next();
      } catch(error) {
        throw error;
      }
      loading.value = false;
    }
  }
}
