import 'package:app/pages/login.dart';
import 'package:app/widgets/ui/drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/routes.dart' as routes;
import 'package:app/controllers/app.dart';
import 'package:app/services/user.dart';

class Destination {
  Destination(this.index, this.title, this.icon, this.color, this.builder);
  int index;
  final String title;
  final IconData icon;
  final MaterialColor color;
  Function builder;
}

List<Destination> allDestinations = <Destination>[
  Destination(0, 'Home', Icons.home, Colors.teal, (_) => HomePageFeed()),
  Destination(1, 'Login', Icons.person, Colors.cyan, (_) => LoginPage())
];

class RootPage extends StatelessWidget {
  const RootPage({ Key key, this.destination }) : super(key: key);

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(destination.title),
        backgroundColor: destination.color,
      ),
      backgroundColor: destination.color[50],
      body: SizedBox.expand(
        child: InkWell(
          onTap: () {
            Get.toNamed('/list', id: destination.index);
          },
        ),
      ),
    );
  }
}

class ListPage extends StatelessWidget {
  const ListPage({ Key key, this.destination }) : super(key: key);

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    const List<int> shades = <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900];

    return Scaffold(
      appBar: AppBar(
        title: Text(destination.title),
        backgroundColor: destination.color,
      ),
      backgroundColor: destination.color[50],
      body: SizedBox.expand(
        child: ListView.builder(
          itemCount: shades.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 128,
              child: Card(
                color: destination.color[shades[index]].withOpacity(0.25),
                child: InkWell(
                  onTap: () {
                    Get.toNamed('/', id: destination.index);
                  },
                  child: Center(
                    child: Text('Item $index', style: Theme.of(context).primaryTextTheme.display1),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DestinationView extends StatefulWidget {
  const DestinationView({ Key key, this.destination, this.content }) : super(key: key);

  final Destination destination;
  final Widget content;

  @override
  _DestinationViewState createState() => _DestinationViewState();
}

class _DestinationViewState extends State<DestinationView> {
  @override
  Widget build(BuildContext context) {
    return widget.content;
  }
}

class HomePageFeed extends StatelessWidget
{
  final UserService userService = Get.find();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Obx(() {
            if (userService.status.value != UserStatus.loggedin) {
              return RaisedButton(
                onPressed: () => Get.toNamed(routes.login), 
                child: Text('login')
              );
            } else {
              return Row(
                children: [
                  Text(userService.user.value.email ?? '?'),
                  RaisedButton(
                    onPressed: () => Get.toNamed(routes.onboarding),
                    child: Text('onboarding')
                  ),
                  RaisedButton(
                    onPressed: () => userService.logout(), 
                    child: Text('logout')
                  )
                ]
              );
            }
          })
        ],
       )
    );
  }
}

class HomePage extends StatefulWidget {
  final AppController appController = Get.find();
  final UserService userService = Get.find();

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin<HomePage> {
  int _currentIndex = 0;
  List<Key> _destinationKeys;
  List<AnimationController> _faders;

  void initState() {  
    super.initState();

    _faders = allDestinations.map<AnimationController>((Destination destination) {
      return AnimationController(vsync: this, duration: Duration(milliseconds: 1200));
    }).toList();
    _faders[_currentIndex].value = 1.0;
    _destinationKeys = List<Key>.generate(allDestinations.length, (int index) => GlobalKey()).toList();
  }

  void dispose() {
    _faders.forEach((f) { f.dispose(); });
    super.dispose();
  }
  
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          fit: StackFit.expand,
          children: allDestinations.map((Destination destination) {

            Widget view = FadeTransition(
              opacity: _faders[destination.index].drive(CurveTween(curve: Curves.fastOutSlowIn)),
              child: KeyedSubtree(
                key: _destinationKeys[destination.index],
                child: destination.builder(context),
              ),
            );

            return Obx(() {
              if (destination.index == widget.appController.navIndex.value) {
                _faders[destination.index].forward();
                return view;
              } else {
                _faders[destination.index].reverse();
                if (_faders[destination.index].isAnimating) {
                  return IgnorePointer(child: view);
                }
                return Offstage(child: view);
              }

            });

          }).toList(),
        )
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: widget.appController.navIndex.value,
        onTap: (int index) {
          widget.appController.navIndex.value = index;
        },
        items: allDestinations.map((Destination destination) {
          return BottomNavigationBarItem(
            icon: Icon(destination.icon),
            backgroundColor: destination.color,
            label: destination.title
          );
        }).toList(),
      )),
    );
  }
}

/*
Column(
        children: [
          Obx(() {
            if (widget.userService.status.value != UserStatus.loggedin) {
              return RaisedButton(
                onPressed: () => Get.toNamed(routes.login), 
                child: Text('login')
              );
            } else {
              return Row(
                children: [
                  Text(widget.userService.user.value.email ?? '?'),
                  RaisedButton(
                    onPressed: () => Get.toNamed(routes.onboarding),
                    child: Text('onboarding')
                  ),
                  RaisedButton(
                    onPressed: () => widget.userService.logout(), 
                    child: Text('logout')
                  )
                ]
              );
            }
          })
        ],
       )
       */