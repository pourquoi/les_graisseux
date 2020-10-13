
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/routes.dart' as routes;
import 'package:app/services/user.dart';

class AppDrawer extends StatelessWidget
{
  final UserService userService = Get.find();

  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Obx(() {
            if (userService.status.value == UserStatus.loggedin) {
              return UserAccountsDrawerHeader(
                accountEmail: Text(userService.user.value.email ?? ''),
                accountName: Text(userService.user.value.username ?? ''),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              );
            } else {
              return DrawerHeader(
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              );
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
            if (userService.status.value == UserStatus.loggedin) {
              return ListTile(
                title: Row(
                  children: [
                    Icon(Icons.logout),
                    Padding(padding: EdgeInsets.only(left: 8.0), child: Text('Logout'))
                  ],
                ),
                onTap: () {
                  userService.logout();
                },
              );
            } else {
              return ListTile(
                title: Row(
                  children: [
                    Icon(Icons.logout),
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