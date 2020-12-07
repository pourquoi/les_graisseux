import 'package:app/controllers/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/routes.dart' as routes;
import 'package:app/controllers/app.dart';
import 'package:app/services/endpoints/user.dart';

class LoginPage extends StatefulWidget
{
  final bool isModal;
  final AppController appController = Get.find();
  final UserController userController = Get.find();

  LoginPage({Key key, this.isModal=false}) : super(key: key);
  
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
{
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController(text: 'alice@example.com');
  final TextEditingController _passwordController = TextEditingController(text: 'pass1234');

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void login() async {
    if (widget.userController.loading.value) return;
    await widget.userController.login(email: _emailController.text, password: _passwordController.text);

    _passwordController.clear();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                colorFilter: ColorFilter.mode(Colors.amber, BlendMode.hue),
                image: AssetImage('assets/images/garage-1.jpg'),
                fit: BoxFit.cover
              )
            )
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.transparent),
                        borderRadius: BorderRadius.circular(15),
                        color: Color.fromRGBO(0, 0, 0, 0.8)
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15), 
                        child: Form(
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
                              Padding(
                                padding: EdgeInsets.all(22),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Obx(() {
                                      return FlatButton(
                                        color: Colors.amberAccent,
                                        onPressed: () => login(),
                                        child: widget.userController.loading.value ? CircularProgressIndicator() : Text('Sign In')
                                      );
                                    }),
                                  ],
                                )
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (widget.isModal) Get.offNamed(routes.onboarding);
                                  else Get.toNamed(routes.onboarding);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text("No account ? Register Here!"),
                                ),
                              )
                            ],
                          )
                        )
                      )
                    ),
                  )
                ],
              )
            ))
          )
        ]
      )
    );
  }
}