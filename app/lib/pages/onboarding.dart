import 'package:app/controllers/app.dart';
import 'package:app/controllers/services.dart';
import 'package:app/controllers/vehicles.dart';
import 'package:app/models/service_tree.dart';
import 'package:app/models/vehicle_tree.dart';
import 'package:app/pages/service_picker.dart';
import 'package:app/pages/vehicle_picker.dart';
import 'package:app/services/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';

import 'package:app/models/user.dart';
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
            title: Text('onboarding.title'.tr),
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
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    left: 32.0 + 8,
                    child: AnimatedSwitcher(
                      child: Obx(() {
                        switch (controller.step.value) {
                          case OnboardingStep.Profile:
                            return StepProfile(key: Key('onboarding.profile'));
                          case OnboardingStep.Services:
                            return StepService(key: Key('onboarding.services'));
                          case OnboardingStep.Vehicle:
                            return StepVehicle(key: Key('onboarding.vehicle'));
                          case OnboardingStep.Account:
                            return StepAccount(key: Key('onboarding.account'));
                          case OnboardingStep.Completed:
                            return StepCompleted(key: Key('onboarding.completed'));
                          default:
                            return StepProfile(key: Key('onboarding.profile'));
                        }
                      }),
                      duration: Duration(milliseconds: 1250),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class StepProfile extends StatelessWidget {
  final OnboardingController controller = Get.find();

  StepProfile({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RaisedButton(
            onPressed: () {
              controller.selectProfile(ProfileType.Customer);
            },
            child: Text('onboarding.profile.choice_customer'.tr)),
        RaisedButton(
            onPressed: () {
              controller.selectProfile(ProfileType.Mechanic);
            },
            child: Text('onboarding.profile.choice_mechanic'.tr))
      ],
    );
  }
}

class StepAccount extends StatefulWidget {
  final OnboardingController controller = Get.find();

  StepAccount({Key key}) : super(key: key);

  _StepAccountState createState() => _StepAccountState();
}

class _StepAccountState extends State<StepAccount> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController;
  TextEditingController _passwordController;

  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void submit(_) {
    if (_formKey.currentState.validate()) {
      widget.controller.register(email: _emailController.text, password: _passwordController.text);
    } else {}
  }

  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          TextFormField(
              controller: _emailController, decoration: InputDecoration(icon: Icon(Icons.email), labelText: 'Email', hintText: 'email'), keyboardType: TextInputType.emailAddress),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(icon: Icon(Icons.lock), labelText: 'Password', hintText: 'password'),
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Obx(() {
                if (widget.controller.loading.value) {
                  return CircularProgressIndicator();
                } else {
                  return RaisedButton(onPressed: () => submit(context), child: Text('ok'));
                }
              }))
        ]));
  }
}

class StepService extends StatefulWidget {
  final ServicesController serviceController = Get.put(ServicesController());
  final OnboardingController controller = Get.find();

  StepService({Key key}) : super(key: key);

  _StepServiceState createState() => _StepServiceState();
}

class _StepServiceState extends State<StepService> {
  TextEditingController _searchController;

  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchQChange);
  }

  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchQChange() {
    widget.serviceController.search(q: _searchController.text);
  }

  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        RaisedButton(
          onPressed: () async {
            ServiceTree service = await Get.to(ServicePicker());
            if (service != null) {
              widget.controller.services.add(service);
            }
          },
          child: Text('add service'),
        ),
        Obx(() {
          return Expanded(
              child: ListView.builder(
            itemCount: widget.controller.services.length,
            itemBuilder: (_, idx) {
              return Text('${idx}' + (widget.controller.services[idx].label ?? ''));
            },
          ));
        }),
        RaisedButton(
            onPressed: () {
              widget.controller.next();
            },
            child: Text('next'))
      ],
    );
  }
}

class StepVehicle extends StatefulWidget {
  final VehiclesController vehiclesController = Get.put(VehiclesController());
  final OnboardingController controller = Get.find();

  StepVehicle({Key key}) : super(key: key);

  _StepVehicleState createState() => _StepVehicleState();
}

class _StepVehicleState extends State<StepVehicle> {
  void _pickVehicle() async {
    VehicleTree vehicle = await Get.to(VehiclePicker());
    widget.controller.vehicle.value = vehicle;
    if (vehicle != null) {}
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          if (widget.controller.vehicle.value.id != null) {
            return Row(
              children: [Text(widget.controller.vehicle.value.name ?? '?'), IconButton(icon: Icon(Icons.close), onPressed: _pickVehicle)],
            );
          } else {
            return RaisedButton(onPressed: _pickVehicle, child: Text('select a car'));
          }
        }),
        RaisedButton(onPressed: () => widget.controller.next(), child: Text('next'))
      ],
    );
  }
}

class StepCompleted extends StatelessWidget {
  final OnboardingController controller = Get.find();

  StepCompleted({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return Center(child: Text('Onboarding complete !'));
  }
}
