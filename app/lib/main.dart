import 'package:app/controllers/account/chat.dart';
import 'package:app/pages/account/profile.dart';
import 'package:app/pages/chat/room.dart';
import 'package:app/pages/chat/rooms.dart';
import 'package:app/services/endpoints/chat.dart';
import 'package:app/widgets/version.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'package:get_storage/get_storage.dart';
import 'package:app/i18n/messages.dart';
import 'package:flutter/services.dart';

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
import 'package:app/pages/jobs/job.dart';
import 'package:app/pages/jobs/jobs.dart';
import 'package:app/pages/login.dart';
import 'package:app/pages/mechanics/mechanic.dart';
import 'package:app/pages/mechanics/mechanics.dart';
import 'package:app/pages/account.dart';
import 'package:app/pages/account/job.dart';
import 'package:app/pages/account/jobs.dart';
import 'package:app/pages/onboarding.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';

void main() async {
  runApp(MyAppBuilder());
}

Future bootstrap() async {
  await GetStorage.init();

  Get.put<ApiService>(ApiService());

  Get.lazyPut<UserService>(() => UserService());
  Get.lazyPut<ServiceTreeService>(() => ServiceTreeService());
  Get.lazyPut<VehicleTreeService>(() => VehicleTreeService());
  Get.lazyPut<MechanicService>(() => MechanicService());
  Get.lazyPut<JobService>(() => JobService());
  Get.lazyPut<JobApplicationService>(() => JobApplicationService());
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

class SplashImage extends StatelessWidget
{
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image(image: AssetImage('assets/images/garage-1.jpg'), fit: BoxFit.cover)
    );
  }
}

class MyAppBuilder extends StatelessWidget {
  Widget build(BuildContext context) {
    Messages messages = Messages();
    String title = messages.keys.containsKey(ui.window.locale.languageCode) ? 
          messages.keys[ui.window.locale.languageCode]['app.title'] :
          messages.keys['en']['app.title'];
    
    return FutureBuilder<dynamic>(
        future: Future.wait([bootstrap(), Future.delayed(Duration(seconds: 2))]),
        builder: (context, snapshot) {
          Widget content;
          if (snapshot.hasData) {
            content = MyApp(key: Key('app'),);
          } else {
            content = MaterialApp(
              key: Key('splash'),
              locale: ui.window.locale,
              home: Stack(
                children: [
                  SplashImage(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(76, 61, 243, 0.5),
                          Color.fromRGBO(120, 58, 183, 0.2),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    ),
                    child: Center(
                      child: Text(title.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 50, decoration: TextDecoration.none))
                    )
                  ),
                  Positioned(
                    bottom: 0, 
                    left: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: CurrentVersionText()
                    )
                  )
                ]
              )
            );
          }
          return AnimatedSwitcher(
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(child: child, opacity: animation);
            },
            duration: Duration(milliseconds: 500),
            child: content,
          );
        });
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  final UserController userController = Get.find();
  final AppController appController = Get.find();

  String get initialRoute {
    if (userController.loggedIn.value || appController.onboardingSkipped.value) {
      return routes.home;
    }

    return routes.onboarding;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    Translations messages = Messages();

    return GetMaterialApp(
      translations: messages,
      locale: Locale('fr'),//ui.window.locale,
      fallbackLocale: Locale('fr'),
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: Colors.amber,
        inputDecorationTheme: InputDecorationTheme(
          
        ),
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routingCallback: (Routing routing) {
        appController.routing = routing;
      },
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
          page: () => AccountPage()
        ),
        GetPage(
          name: routes.profile,
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
