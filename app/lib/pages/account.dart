import 'package:app/controllers/app.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/user.dart';
import 'package:app/widgets/ui/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/routes.dart' as routes;

class AccountPage extends StatelessWidget
{
  final UserController userController = Get.find();
  final AppController appController = Get.find();
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() => Text(userController.user.value.email ?? '')),
            Obx(() => Text(userController.user.value.username ?? '')),
            ProfilePictureWidget(),
            Obx(() {
              User user = userController.user.value;
              if (user.customer == null && user.mechanic == null) {
                return ListTile(
                  title: RaisedButton(onPressed: () => Get.toNamed(routes.onboarding), child: Text('complet profile'))
                );
              } else if (user.customer == null) {
                return ListTile(
                  title: RaisedButton(onPressed: () => Get.toNamed(routes.onboarding, arguments: {'type': ProfileType.Customer}), child: Text('post a job'))
                );
              } else if (user.mechanic == null) {
                return ListTile(
                  title: RaisedButton(onPressed: () => Get.toNamed(routes.onboarding, arguments: {'type': ProfileType.Mechanic}), child: Text('create my mechanic'))
                );
              } else {
                return ListTile(
                  title: RaisedButton(
                    onPressed: () {
                      if (appController.profileType.value == ProfileType.Mechanic) {
                        appController.profileType.value = ProfileType.Customer;
                      } else {
                        appController.profileType.value = ProfileType.Mechanic;
                      }
                    }, 
                    child: appController.profileType.value == ProfileType.Mechanic ? Text('switch to customer') : Text('switch to mechanic')
                  )
                );
              }
            }),
            ListTile(
              title: Text('Profile'),
              onTap: () => Get.toNamed(routes.profile),
            ),
            OutlinedButton(onPressed: () {
              userController.logout();
            }, child: Text('logout'))
          ]
        )
      )
    );
  }
}