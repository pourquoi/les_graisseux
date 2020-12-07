
import 'package:app/controllers/account/job.dart';
import 'package:app/controllers/onboarding.dart';
import 'package:app/models/service_tree.dart';
import 'package:app/pages/onboarding/common.dart';
import 'package:app/widgets/popup/service_picker.dart';
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
      children: [
        Spacer(),
        Obx(() =>  widget.jobController.job.value.tasks.length > 0 ?
          ItemFader(
            itemCount: 2,
            itemIndex: 0,
            key: keys[0],
            child: Wrap(
              children: widget.jobController.job.value.tasks.map((task) => 
                Chip(
                  label: Text((task.label ?? ''), overflow: TextOverflow.clip,),
                  onDeleted: () => stepController.removeTask(task),
                )
              ).toList()
            )  
          )
          :
          SizedBox.shrink()
        ),
        ItemFader(
          itemCount: 2,
          itemIndex: 1,
          key: keys[1],
          child:
          OutlineButton(
            key: keys[0],
            onPressed: () async {
              ServiceTree service = await showSearch(context: context, delegate: ServiceSearch());
              if (service != null) {
                stepController.addTask(service);
              }
            },
            child: Obx(() => widget.jobController.job.value.tasks.length == 0 ? 
            Text('Pick a service') : Text('Add a service')
            )
          )
        ),
        Spacer(),
        Obx(() =>  widget.jobController.job.value.tasks.length > 0 ?
        Align(
          alignment: Alignment.bottomRight,
          child: RaisedButton(
            onPressed: () => submit(),
            child: Icon(Icons.navigate_next_rounded)
          ),
        ) : SizedBox.shrink())
      ],
    );
  }
}
