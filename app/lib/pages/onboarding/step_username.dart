
import 'package:app/controllers/onboarding.dart';
import 'package:app/pages/onboarding/common.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepUsername extends StatefulWidget {
  final OnboardingController controller = Get.find();

  StepUsername({Key key}) : super(key: key);

  _StepUsernameState createState() => _StepUsernameState();
}

class _StepUsernameState extends State<StepUsername> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController;

  OnboardingProfile get stepController => widget.controller.steps[OnboardingStep.Profile];

  List<GlobalKey<ItemFaderState>> keys;

  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.controller.userController.user.value.username ?? '');
    keys = List.generate(1, (_) => GlobalKey<ItemFaderState>());
  }

  void submit() async {
    if (_formKey.currentState.validate()) {
      try {
        await widget.controller.userController.editUsername(_usernameController.text);
        for (GlobalKey<ItemFaderState> key in keys) {
          if (key.currentState != null) {
            await key.currentState.hide();
          }
        }
        widget.controller.next();
      } catch (err) {
      }
    }
  }

  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 32),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(left: 64, right: 32),
            child: ItemFader(
              itemCount: 1,
              itemIndex: 0,
              key: keys[0],
              child: TextFormField(
                controller: _usernameController,
                style: TextStyle(color: Colors.orange),
                decoration: InputDecoration(
                  icon: Icon(Icons.lock, color: Colors.orange,), 
                  labelStyle: TextStyle(color: Colors.orange),
                  labelText: 'Username', 
                  hintText: 'username'
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'input.required';
                  }
                  return null;
                },
              ),
            )
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
        ]
      )
    );
  }
}
