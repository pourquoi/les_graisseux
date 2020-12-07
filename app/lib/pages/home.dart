import 'dart:async';
import 'dart:math';

import 'package:app/controllers/user.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/account.dart';
import 'package:app/pages/account/jobs.dart';
import 'package:app/pages/chat/rooms.dart';
import 'package:app/pages/jobs/jobs.dart';
import 'package:app/pages/login.dart';
import 'package:app/pages/mechanics/mechanics.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:app/controllers/app.dart';

class HomeTab {
  int index;
  final String title;
  final IconData icon;
  final MaterialColor color;
  Function builder;

  HomeTab(this.index, this.title, this.icon, this.color, this.builder);
}


class HomePage extends StatefulWidget {
  final AppController appController = Get.find();
  final UserController userController = Get.find();

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin<HomePage> {
  int _currentIndex = 0;
  List<Key> _destinationKeys;
  List<AnimationController> _faders;

  List<HomeTab> _tabs = <HomeTab>[];

  StreamSubscription _profileTypeStream;
  StreamSubscription _statusStream;

  void initState() {
    super.initState();

    _profileTypeStream = widget.appController.profileType.listen((_) {
      _buildTabs();
    });

    _statusStream = widget.userController.loggedIn.listen((_) { 
      _buildTabs();
    });

    _buildTabs();
  }

  void dispose() {
    _faders.forEach((f) { f.dispose(); });
    _profileTypeStream.cancel();
    _statusStream.cancel();
    super.dispose();
  }

  void _buildTabs() {
    List<HomeTab> tabs;
    if (widget.userController.loggedIn.value) {

      if (widget.appController.profileType.value == ProfileType.Mechanic) {
        tabs = [
          HomeTab(0, 'home.tabs.jobs'.tr, FontAwesomeIcons.carCrash, Colors.cyan, (_) => JobsPage()),
          HomeTab(1, 'home.tabs.messages'.tr, FontAwesomeIcons.comments, Colors.red, (_) => ChatRoomsPage()),
          HomeTab(2, 'home.tabs.account'.tr, FontAwesomeIcons.cogs, Colors.yellow, (_) => AccountPage())
        ];
      } else {
        tabs = [
          HomeTab(0, 'home.tabs.mechanics'.tr, FontAwesomeIcons.users, Colors.cyan, (_) => MechanicsPage()),
          HomeTab(1, 'home.tabs.jobs'.tr, FontAwesomeIcons.carCrash, Colors.cyan, (_) => AccountJobsPage()),
          HomeTab(2, 'home.tabs.messages'.tr, FontAwesomeIcons.comments, Colors.red, (_) => ChatRoomsPage()),
          HomeTab(3, 'home.tabs.account'.tr, FontAwesomeIcons.cogs, Colors.yellow, (_) => AccountPage())
        ];
      }
    } else {
      tabs = [
        HomeTab(0, 'home.tabs.jobs'.tr, FontAwesomeIcons.carCrash, Colors.cyan, (_) => JobsPage()),
        HomeTab(1, 'home.tabs.mechanics'.tr, FontAwesomeIcons.users, Colors.cyan, (_) => MechanicsPage()),
        HomeTab(2, 'home.tabs.account'.tr, FontAwesomeIcons.cogs, Colors.yellow, (_) => LoginPage())
      ];
    }

    if (_faders != null)
      _faders.forEach((f) { f.dispose(); });

    _tabs = tabs;
    _faders = _tabs.map<AnimationController>((HomeTab destination) {
      return AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    }).toList();
    _currentIndex = 0;
    _faders[_currentIndex].value = 1.0;
    _destinationKeys = List<Key>.generate(_tabs.length, (int index) => GlobalKey()).toList();

    setState(() {});
  }
  
  Widget build(BuildContext context) {
    double maxSlide = Get.width;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          fit: StackFit.expand,
          children: _tabs.map((HomeTab destination) {

            Widget view = AnimatedBuilder(
              key: _destinationKeys[destination.index],
              animation: _faders[destination.index],
              builder: (_, child) {
                final Animation curve = CurvedAnimation(parent: _faders[destination.index], curve: Curves.easeOut, reverseCurve: Curves.easeIn);
                double animValue = curve.value;
                double angle = (1-animValue) * pi/2;

                if (destination.index == _currentIndex) {
                  return Transform.translate(
                    offset: Offset(maxSlide * (1-animValue), 0),
                    child: Transform(
                      alignment: Alignment.centerLeft,
                      transform: new Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(-angle),
                      child: destination.builder(context),
                    )
                  );
                } else {
                  return Transform.translate(
                    offset: Offset(-maxSlide * (1-animValue), 0),
                    child: Transform(
                      alignment: Alignment.centerRight,
                      transform: new Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: destination.builder(context),
                    )
                  );
                }
              }
            );

            if (destination.index == _currentIndex) {
              _faders[destination.index].forward();
              return view;
            } else {
              _faders[destination.index].reverse();
              if (_faders[destination.index].isAnimating) {
                return IgnorePointer(child: view);
              }
              return Offstage(child: view);
            }
          }).toList(),
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amberAccent,
        unselectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _tabs.map((HomeTab destination) {
          return BottomNavigationBarItem(
            backgroundColor: Colors.black,
            activeIcon: Icon(destination.icon, color: Colors.amberAccent,),
            icon: Icon(destination.icon, color: Colors.white,),
            label: destination.title
          );
        }).toList(),
      ),
    );
  }
}
