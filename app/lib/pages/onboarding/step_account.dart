
// register user (email, password)

import 'package:app/controllers/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepAccount extends StatefulWidget {
  final OnboardingController controller = Get.find();

  StepAccount({Key key}) : super(key: key);

  _StepAccountState createState() => _StepAccountState();
}

class _StepAccountState extends State<StepAccount> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController;
  TextEditingController _passwordController;

  OnboardingAccount get stepController => widget.controller.currentController;

  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'bob${(new DateTime.now()).millisecondsSinceEpoch}@example.com');
    _passwordController = TextEditingController(text: 'pass1234');
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void submit(_) {
    if (_formKey.currentState.validate()) {
      stepController.register(email: _emailController.text, password: _passwordController.text).then((_) {
        
      });
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
            decoration: InputDecoration(
              icon: Icon(Icons.lock), 
              labelText: 'Password', 
              hintText: 'password'
            ),
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
