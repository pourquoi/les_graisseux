
import 'package:app/controllers/onboarding.dart';
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

  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.controller.userController.user.value.username ?? '');
  }

  void submit() async {
    if (_formKey.currentState.validate()) {
      try {
        await widget.controller.userController.editUsername(_usernameController.text);
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
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              icon: Icon(Icons.lock), 
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
          RaisedButton(
            onPressed: () => submit(),
            child: Text('Ok')
          )
        ]
      )
    );
  }
}
