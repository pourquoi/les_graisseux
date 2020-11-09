
import 'package:app/controllers/account/job.dart';
import 'package:app/controllers/onboarding.dart';
import 'package:app/models/vehicle_tree.dart';
import 'package:app/pages/onboarding/common.dart';
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

  List<GlobalKey<ItemFaderState>> keys;

  void initState() {
    super.initState();
    _kmController = TextEditingController();
    keys = List.generate(1, (_) => GlobalKey<ItemFaderState>());
  }

  void _pickVehicle() async {
    VehicleTree vehicle = await Get.to(VehiclePicker());

    stepController.setVehicle(vehicle);
  }

  void submit() async {
    widget.controller.loading.value = true;
    if (widget.jobController.job.value.vehicle != null) {
      try {
        widget.jobController.job.value.vehicle.km = int.parse(_kmController.text);
      } catch(error) {
        widget.jobController.job.value.vehicle.km = null;
      }
    }

    for (GlobalKey<ItemFaderState> key in keys) {
      if (key.currentState != null) {
        await key.currentState.hide();
      }
    }
    widget.controller.next();
    widget.controller.loading.value = false;
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 32),
        Spacer(),
        Padding(
          padding: EdgeInsets.only(left: 64, right: 8),
          child: Obx(() {
            if (widget.jobController.job.value.vehicle != null && widget.jobController.job.value.vehicle.type != null) {
              return Row(
                children: [
                  Text(widget.jobController.job.value.vehicle.type.name ?? '?'), 
                  IconButton(icon: Icon(Icons.close), onPressed: _pickVehicle)
                ],
              );
            } else {
              return RaisedButton(
                onPressed: _pickVehicle, 
                child: Text('select a car')
              );
            }
          })
        ),
        Obx(() => (widget.jobController.job.value.vehicle != null && widget.jobController.job.value.vehicle.type != null) ?
          Padding(
            padding: EdgeInsets.only(left: 64, right: 8),
            child: TextFormField(
              controller: _kmController, 
              decoration: InputDecoration(
                icon: Icon(Icons.email), 
                labelText: 'Km', 
                hintText: 'km'
              ), 
              keyboardType: TextInputType.number
            ),
          ) : SizedBox.shrink()
        ),
        SizedBox(height: 24,),
        Padding(
          padding: EdgeInsets.only(left: 64, right: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() => RaisedButton(
                onPressed: () => widget.controller.loading.value ? null : submit(),
                child: widget.controller.loading.value ? CircularProgressIndicator() : Icon(Icons.navigate_next_rounded)
              )),
            ]
          )
        ),
        Spacer(),
      ],
    );
  }
}
