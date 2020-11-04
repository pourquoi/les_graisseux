import 'package:app/widgets/ui/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:app/controllers/app.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/user.dart';
import 'package:get/get.dart';
import 'package:app/routes.dart' as routes;

class AppDrawer extends StatelessWidget
{
  final AppController appController = Get.find();
  final UserController userController = Get.find();

  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Obx(() {
            if (userController.status.value == UserStatus.loggedin) {
              return UserAccountsDrawerHeader(
                margin: EdgeInsets.only(bottom: 40.0),  
                onDetailsPressed: () => Get.offAndToNamed(routes.account),
                accountEmail: Text(userController.user.value.email ?? ''),
                accountName: Text(userController.user.value.username ?? ''),
                currentAccountPicture: ProfilePictureWidget(),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              );
            } else {
              return DrawerHeader(
                child: Text('app.title'.tr),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              );
            }
          }),

          Obx(() {
            if (userController.status.value == UserStatus.loggedin) {
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
            } else {
              return SizedBox.shrink();
            }
          }),

          Obx(() {
            if (userController.status.value == UserStatus.loggedin && userController.user.value.customer != null) {
              return ListTile(
                title: Row(
                  children: [
                    Icon(Icons.list),
                    Padding(padding: EdgeInsets.only(left: 8.0), child: Text('My jobs'))
                  ]
                ),
                onTap: () { Get.offAndToNamed(routes.account_jobs); },
              );
            } else {
              return SizedBox.shrink();
            }
          }),

          Obx(() {
            if (userController.status.value == UserStatus.loggedin) {
              return ListTile(
                title: Row(
                  children: [
                    Icon(Icons.list),
                    Padding(padding: EdgeInsets.only(left: 8.0), child: Text('Messages'))
                  ]
                ),
                onTap: () { Get.offAndToNamed(routes.chat_rooms); },
              );
            } else {
              return SizedBox.shrink();
            }
          }),

          ListTile(
            title: Row(
              children: [
                Icon(Icons.list),
                Padding(padding: EdgeInsets.only(left: 8.0), child: Text('Mechanics'))
              ]
            ),
            onTap: () { Get.offAndToNamed(routes.mechanics); },
          ),

          ListTile(
            title: Row(
              children: [
                Icon(Icons.list),
                Padding(padding: EdgeInsets.only(left: 8.0), child: Text('Jobs'))
              ]
            ),
            onTap: () { Get.offAndToNamed(routes.jobs); },
          ),


          Obx(() {
            if (userController.status.value == UserStatus.loggedin) {
              return ListTile(
                title: Row(
                  children: [
                    Icon(Icons.logout),
                    Padding(padding: EdgeInsets.only(left: 8.0), child: Text('Logout'))
                  ],
                ),
                onTap: () {
                  userController.logout();
                },
              );
            } else {
              return ListTile(
                title: Row(
                  children: [
                    Icon(Icons.login),
                    Padding(padding: EdgeInsets.only(left: 8.0), child: Text('Login'))
                  ],
                ),
                onTap: () {
                  Get.offAndToNamed(routes.login);
                },
              );
            }
          })
          

        ],
      ),
    );
  }
}