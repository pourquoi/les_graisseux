import 'package:app/controllers/account/chat.dart';
import 'package:app/pages/account/profile.dart';
import 'package:app/pages/chat/room.dart';
import 'package:app/pages/chat/rooms.dart';
import 'package:app/services/endpoints/chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'package:get_storage/get_storage.dart';
import 'package:app/i18n/messages.dart';

import 'package:app/routes.dart' as routes;

import 'package:app/services/api.dart';
import 'package:app/services/endpoints/customer.dart';
import 'package:app/services/endpoints/job.dart';
import 'package:app/services/endpoints/mechanic.dart';
import 'package:app/services/endpoints/service_tree.dart';
import 'package:app/services/endpoints/user.dart';
import 'package:app/services/endpoints/vehicle_tree.dart';

import 'package:app/controllers/account/job.dart';
import 'package:app/controllers/account/mechanic.dart';
import 'package:app/controllers/user.dart';
import 'package:app/controllers/app.dart';

import 'package:app/pages/home.dart';
import 'package:app/pages/job.dart';
import 'package:app/pages/jobs.dart';
import 'package:app/pages/login.dart';
import 'package:app/pages/mechanic.dart';
import 'package:app/pages/mechanics.dart';
import 'package:app/pages/account.dart';
import 'package:app/pages/account/job.dart';
import 'package:app/pages/account/jobs.dart';
import 'package:app/pages/onboarding.dart';
import 'package:intl/intl.dart';

void main() async {
  runApp(MyAppBuilder());
}

Future<dynamic> bootstrap() async {
  await GetStorage.init();

  Get.put<ApiService>(ApiService());

  Get.lazyPut<UserService>(() => UserService());
  Get.lazyPut<ServiceTreeService>(() => ServiceTreeService());
  Get.lazyPut<VehicleTreeService>(() => VehicleTreeService());
  Get.lazyPut<MechanicService>(() => MechanicService());
  Get.lazyPut<JobService>(() => JobService());
  Get.lazyPut<CustomerService>(() => CustomerService());
  Get.lazyPut<ChatRoomService>(() => ChatRoomService());
  Get.lazyPut<ChatMessageService>(() => ChatMessageService());

  AppController appController = Get.put(AppController());

  UserController userController = Get.put<UserController>(UserController());
  Get.put<AccountJobController>(AccountJobController());
  Get.put<AccountMechanicController>(AccountMechanicController());
  Get.put<ChatController>(ChatController());

  await appController.bootstrap();
  await userController.bootstrap();

  return true;
}

class MyAppBuilder extends StatelessWidget {
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: bootstrap(),
        builder: (context, snapshot) {
          Widget content;
          if (snapshot.hasData) {
            content = MyApp();
          } else {
            content = Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(76, 61, 243, 1),
                    Color.fromRGBO(120, 58, 183, 1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              ),
              child: Center(
                child: Image(image: AssetImage('assets/images/logo.jpg'), width: 150)
              )
            );
          }
          return AnimatedSwitcher(
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(child: child, opacity: animation);
            },
            duration: Duration(milliseconds: 2000),
            child: content,
          );
        });
  }
}

class MyApp extends StatelessWidget {
  final UserController userController = Get.find();
  final AppController appController = Get.find();

  String get initialRoute {
    if (userController.status.value == UserStatus.loggedin) {
      return routes.account;
    }

    if (userController.user.value.email != null) {
      return routes.login;
    }

    if (appController.onboardingSkipped.value) {
      return routes.mechanics;
    }

    return routes.onboarding;
  }

  @override
  Widget build(BuildContext context) {
    Translations messages = Messages();

    return GetMaterialApp(
      translations: messages,
      locale: ui.window.locale,
      fallbackLocale: Locale('en', 'US'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialRoute,
      getPages: [
        GetPage(
            name: routes.home,
            page: () => HomePage()
        ),
        GetPage(
          name: routes.login,
          page: () => LoginPage()
        ),
        GetPage(
          name: routes.onboarding, 
          page: () => OnboardingPage()
        ),
        GetPage(
          name: routes.jobs,
          page: () => JobsPage()
        ),
        GetPage(
          name: routes.job,
          page: () => JobPage()
        ),
        GetPage(
          name: routes.mechanics,
          page: () => MechanicsPage()
        ),
        GetPage(
          name: routes.mechanic,
          page: () => MechanicPage()
        ),
        GetPage(
          name: routes.account,
          page: () => ProfilePage()
        ),
        GetPage(
          name: routes.account_jobs,
          page: () => AccountJobsPage()
        ),
        GetPage(
          name: routes.account_job,
          page: () => AccountJobPage()
        ),
        GetPage(
          name: routes.chat_rooms,
          page: () => ChatRoomsPage()
        ),
        GetPage(
          name: routes.chat_room,
          page: () => ChatRoomPage()
        )
      ],
    );
  }
}
