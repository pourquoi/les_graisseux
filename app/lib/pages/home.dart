import 'dart:math';

import 'package:app/controllers/user.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/account.dart';
import 'package:app/pages/account/profile.dart';
import 'package:app/pages/chat/room.dart';
import 'package:app/pages/chat/rooms.dart';
import 'package:app/pages/jobs.dart';
import 'package:app/pages/login.dart';
import 'package:app/pages/mechanics.dart';
import 'package:app/widgets/ui/drawer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:app/routes.dart' as routes;
import 'package:app/controllers/app.dart';
import 'package:app/services/endpoints/user.dart';

class HomeTab {
  HomeTab(this.index, this.title, this.icon, this.color, this.builder);
  int index;
  final String title;
  final IconData icon;
  final MaterialColor color;
  Function builder;
}

class HomeTabView extends StatefulWidget {
  const HomeTabView({ Key key, this.destination, this.content }) : super(key: key);

  final HomeTab destination;
  final Widget content;

  @override
  _HomeTabViewState createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  @override
  Widget build(BuildContext context) {
    return widget.content;
  }
}

class HomePage extends StatefulWidget {
  final AppController appController = Get.find();
  final UserController userController = Get.find();

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin<HomePage> {
  int _currentIndex = 0;
  int _lastIndex = 0;
  List<Key> _destinationKeys;
  List<AnimationController> _faders;

  List<HomeTab> _tabs = <HomeTab>[];

  void initState() {
    super.initState();

    widget.appController.profileType.listen((_) {
      _buildTabs();
    });

    widget.userController.status.listen((_) { 
      _buildTabs();
    });

    _buildTabs();
  }

  void dispose() {
    _faders.forEach((f) { f.dispose(); });
    super.dispose();
  }

  void _buildTabs() {
    List<HomeTab> tabs;
    if (widget.userController.status.value == UserStatus.loggedin) {
      tabs = [
        (widget.appController.profileType.value == ProfileType.Mechanic ?
          HomeTab(0, 'Jobs', Icons.search, Colors.cyan, (_) => JobsPage()) :
          HomeTab(0, 'Mechanics', Icons.search, Colors.cyan, (_) => MechanicsPage())
        ),
        HomeTab(1, 'Messages', FontAwesomeIcons.comments, Colors.red, (_) => ChatRoomsPage()),
        HomeTab(2, 'Account', FontAwesomeIcons.user, Colors.yellow, (_) => AccountPage())
      ];
    } else {
      tabs = [
        (widget.appController.profileType.value == ProfileType.Mechanic ?
          HomeTab(0, 'Jobs', Icons.search, Colors.cyan, (_) => MechanicsPage()) :
          HomeTab(0, 'Mechanics', Icons.search, Colors.cyan, (_) => JobsPage())
        ),
        HomeTab(1, 'Login', FontAwesomeIcons.user, Colors.yellow, (_) => LoginPage()),
        HomeTab(2, 'Login', FontAwesomeIcons.user, Colors.yellow, (_) => LoginPage())
      ];
    }

    if (_faders != null)
      _faders.forEach((f) { f.dispose(); });

    _tabs = tabs;
    _faders = _tabs.map<AnimationController>((HomeTab destination) {
      return AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    }).toList();
    _currentIndex = 0;
    _lastIndex = 0;
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
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _lastIndex = _currentIndex;
            _currentIndex = index;
          });
        },
        items: _tabs.map((HomeTab destination) {
          return BottomNavigationBarItem(
            icon: Icon(destination.icon),
            backgroundColor: destination.color,
            label: destination.title
          );
        }).toList(),
      ),
    );
  }
}
