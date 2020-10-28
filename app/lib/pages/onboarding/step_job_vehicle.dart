
import 'package:app/controllers/account/job.dart';
import 'package:app/controllers/onboarding.dart';
import 'package:app/controllers/vehicles.dart';
import 'package:app/models/customer_vehicle.dart';
import 'package:app/models/vehicle_tree.dart';
import 'package:app/pages/vehicle_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepJobVehicle extends StatefulWidget {
  final OnboardingController controller = Get.find();
  final AccountJobController jobController = Get.find();

  StepJobVehicle({Key key}) : super(key: key);

  _StepJobVehicleState createState() => _StepJobVehicleState();
}

class _StepJobVehicleState extends State<StepJobVehicle> {
  TextEditingController _kmController;

  OnboardingJobVehicle get stepController => widget.controller.steps[OnboardingStep.JobVehicle];

  void initState() {
    super.initState();
    _kmController = TextEditingController();
  }

  void _pickVehicle() async {
    VehicleTree vehicle = await Get.to(VehiclePicker());

    stepController.setVehicle(vehicle);
  }

  void submit() {
    if (widget.jobController.job.value.vehicle != null) {
      try {
        widget.jobController.job.value.vehicle.km = int.parse(_kmController.text);
      } catch(error) {
        widget.jobController.job.value.vehicle.km = null;
      }
    }
    widget.controller.next();
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          if (widget.jobController.job.value.vehicle != null && widget.jobController.job.value.vehicle.type != null) {
            return Row(
              children: [Text(widget.jobController.job.value.vehicle.type.name ?? '?'), IconButton(icon: Icon(Icons.close), onPressed: _pickVehicle)],
            );
          } else {
            return RaisedButton(onPressed: _pickVehicle, child: Text('select a car'));
          }
        }),
        TextFormField(
          controller: _kmController, 
          decoration: InputDecoration(
            icon: Icon(Icons.email), 
            labelText: 'Km', 
            hintText: 'km'
          ), 
          keyboardType: TextInputType.number
        ),
        RaisedButton(onPressed: () => submit(), child: Text('next'))
      ],
    );
  }
}
