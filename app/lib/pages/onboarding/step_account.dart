
// register user (email, password)

import 'package:app/controllers/onboarding.dart';
import 'package:app/pages/onboarding/common.dart';
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

  List<GlobalKey<ItemFaderState>> keys;

  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'bob${(new DateTime.now()).millisecondsSinceEpoch}@example.com');
    _passwordController = TextEditingController(text: 'pass1234');
    keys = List.generate(2, (index) => GlobalKey<ItemFaderState>());
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void submit() {
    if (_formKey.currentState.validate()) {
      stepController.register(email: _emailController.text, password: _passwordController.text).then((_) {
        
      });
    } else {}
  }

  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: <Widget>[
            SizedBox(height: 32),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(left: 64, right: 8),
              child: ItemFader(
                key: keys[0],
                itemCount: 2,
                itemIndex: 0,
                child: TextFormField(
                  controller: _emailController, 
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    icon: Icon(Icons.email, color: Colors.orange,), 
                    labelText: 'Email', 
                    labelStyle: TextStyle(color: Colors.orange),
                    hintText: 'email'
                  ), 
                  keyboardType: TextInputType.emailAddress
                )
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 64, right: 8),
              child: ItemFader(
                key: keys[1],
                itemCount: 2,
                itemIndex: 0,
                child: TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock, color: Colors.orange,),
                    labelStyle: TextStyle(color: Colors.orange), 
                    labelText: 'Password', 
                    hintText: 'password'
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                )
              ),
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
        ]));
  }
}
