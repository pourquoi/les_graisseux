
import 'package:app/controllers/account/job.dart';
import 'package:app/controllers/onboarding.dart';
import 'package:app/models/vehicle_tree.dart';
import 'package:app/pages/onboarding/common.dart';
import 'package:app/widgets/popup/vehicle_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  void _pickVehicle(BuildContext context) async {
    VehicleTree vehicle = await showSearch(context: context, delegate: VehicleSearch());

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
        Obx(() {
          if (widget.jobController.job.value.vehicle != null && widget.jobController.job.value.vehicle.type != null) {
            return Card(
              margin: EdgeInsets.all(0),
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                children: [
                  Row(
                    children: [
                      Text(widget.jobController.job.value.vehicle.type.fullName ?? '?'),
                      Spacer() ,
                      IconButton(
                        icon: Icon(Icons.close), 
                        onPressed: () => stepController.setVehicle(null)
                      )
                    ],
                  ),
                  TextFormField(
                    controller: _kmController, 
                    decoration: InputDecoration(
                      suffix: Text('km'),
                      icon: Icon(FontAwesomeIcons.tachometerAlt), 
                      hintText: 'kilométrage'
                    ), 
                    keyboardType: TextInputType.number
                  )
                ]
              ))
            );
          } else {
            return OutlineButton(
              onPressed: () => _pickVehicle(context), 
              child: Text('Pick a car')
            );
          }
        }),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Obx(() => RaisedButton(
              onPressed: () => widget.controller.loading.value ? null : submit(),
              child: widget.controller.loading.value ? CircularProgressIndicator() : Icon(Icons.navigate_next_rounded)
            )),
          ]
        )
      ],
    );
  }
}
