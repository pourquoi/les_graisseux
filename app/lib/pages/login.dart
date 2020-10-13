import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/routes.dart' as routes;
import 'package:app/controllers/app.dart';
import 'package:app/services/user.dart';

class LoginPage extends StatefulWidget
{
  final AppController appController = Get.find();
  final UserService userService = Get.find();
  
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
{
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void login() {
    widget.userService.login(email: _emailController.text, password: _passwordController.text).then((user) {
      Get.toNamed(routes.home);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'email'
                    ),
                  ),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      hintText: 'password',
                    ),
                    obscureText: true,
                  ),
                  Obx(() {
                    if (widget.userService.loading.value) {
                      return CircularProgressIndicator();
                    } else {
                      return RaisedButton(
                        onPressed: () => login(),
                        child: Text('login')
                      );
                    }
                  }),
                  RaisedButton(
                    onPressed: () => Get.offAndToNamed(routes.onboarding),
                    child: Text('register')
                  )
                ],
              )
            )
          ],
        )
      )
    );
  }
}