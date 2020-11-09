
import 'package:app/controllers/account/job.dart';
import 'package:app/controllers/onboarding.dart';
import 'package:app/models/service_tree.dart';
import 'package:app/pages/onboarding/common.dart';
import 'package:app/pages/service_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepJobServices extends StatefulWidget {
  final OnboardingController controller = Get.find();
  final AccountJobController jobController = Get.find();

  StepJobServices({Key key}) : super(key: key);

  _StepJobServicesState createState() => _StepJobServicesState();
}

class _StepJobServicesState extends State<StepJobServices> {

  OnboardingJobServices get stepController => widget.controller.steps[OnboardingStep.JobServices];

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
      children: [
        SizedBox(height: 32),
        Spacer(),
        ItemFader(
          key: keys[0],
          itemCount: 2,
          itemIndex: 0,
          child: Align(
                  alignment: Alignment.center,
            child: Text(stepController.title, style: TextStyle(color: Colors.white, fontSize: 20))
          ),
        ),

        SizedBox(height: 32),

        Obx(() =>  widget.jobController.job.value.tasks.length > 0 ?
          Flexible(
          child: Padding(
            padding: EdgeInsets.only(left: 64, right: 8),
            child: ItemFader(
              itemCount: 2,
              itemIndex: 1,
              key: keys[1],
              child: ListView.builder(
                itemCount: widget.jobController.job.value.tasks.length,
                itemBuilder: (_, idx) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text((widget.jobController.job.value.tasks[idx].label ?? ''), style: TextStyle(color: Colors.black, fontSize: 20), overflow: TextOverflow.clip,)
                        ),
                        IconButton(
                          iconSize: 20,
                          icon: Icon(Icons.close_rounded, color: Colors.black,), 
                          onPressed: () => stepController.removeTask(widget.jobController.job.value.tasks[idx])
                        )
                      ]
                    );
                },
              )
            )
          )) :
          SizedBox.shrink()
        ),

        Padding(
          padding: EdgeInsets.only(left: 32, right: 8),
          child: 
          Obx(() => widget.jobController.job.value.tasks.length == 0 ? 
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: RaisedButton(
                    key: keys[0],
                    onPressed: () async {
                      ServiceTree service = await Get.to(ServicePicker());
                      if (service != null) {
                        stepController.addTask(service);
                      }
                    },
                    child: Text('Select a service')
                  )
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => submit(),
                    child: Text('skip')
                  ),
                )
              ]
            ) :
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: RaisedButton(
                    onPressed: () async {
                      ServiceTree service = await Get.to(ServicePicker());
                      if (service != null) {
                        stepController.addTask(service);
                      }
                    },
                    child: Text('Add a service')
                  )
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: RaisedButton(
                    color: Colors.greenAccent,
                    onPressed: () => submit(),
                    child: Text('Next')
                  ),
                )
              ]
            ),
          )
        ),

        Spacer(),
      ],
    );
  }
}
