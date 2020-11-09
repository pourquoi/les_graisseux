import 'dart:async';

import 'package:app/models/mechanic.dart';
import 'package:app/widgets/ui/drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/models/service_tree.dart';
import 'package:app/models/user.dart';
import 'package:app/models/vehicle_tree.dart';

import 'package:app/controllers/account/mechanic.dart';
import 'package:app/controllers/app.dart';

import 'package:app/pages/service_picker.dart';
import 'package:app/pages/vehicle_picker.dart';
import 'package:app/widgets/ui/stars.dart';

class ProfilePage extends StatefulWidget
{
  AppController appController = Get.find();

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
{
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.appController.profileType.value == ProfileType.Customer) {
        return CustomerProfilePage();
      } else {
        return MechanicProfilePage();
      }
    });
  }
}

class MechanicProfilePage extends StatefulWidget
{
  final AccountMechanicController controller = Get.find();

  _MechanicProfilePageState createState() => _MechanicProfilePageState();
}

class _MechanicProfilePageState extends State<MechanicProfilePage>
{
  void initState() {
    super.initState();
    widget.controller.load();
  }

  Widget build(BuildContext context)
  {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car)),
              Tab(icon: Icon(Icons.directions_transit)),
              Tab(icon: Icon(Icons.directions_bike)),
            ],
          ),
          title: Text('Mechanic Account'),
        ),
        body: TabBarView(
          children: [
            MechanicInfoTab(),
            MechanicServicesTab(),
            Icon(Icons.directions_bike),
          ],
        ),
      ),
    );
  }
}

class MechanicServicesForm extends StatelessWidget
{
  final AccountMechanicController controller;

  MechanicServicesForm({Key key, this.controller}) : super(key: key);

  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.mechanic.value.services.length > 0) {
        return Column(
          children: controller.mechanic.value.services.map((mservice) {
            return Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          controller.mechanic.value.services.remove(mservice);
                          controller.mechanic.refresh();
                        }
                      )
                    ]
                  ),
                  ListTile(
                    leading: Icon(Icons.car_repair),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        VehicleTree vehicle = await Get.to(VehiclePicker());
                        if (vehicle != null) {
                          mservice.vehicle = vehicle;
                          controller.mechanic.refresh();
                        }
                      },
                    ),
                    title: mservice.vehicle != null ? Text(mservice.vehicle.name) : Text('-'),
                  ),
                  ListTile(
                    leading: Icon(Icons.build_rounded),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        ServiceTree service = await Get.to(ServicePicker());
                        if (service != null) {
                          mservice.service = service;
                          controller.mechanic.refresh();
                        }
                      },
                    ),
                    title: mservice.service != null ? Text(mservice.service.label) : Text('-'),
                  ),
                  ListTile(
                    title: Center(child: StarRating(
                      value: mservice.skill,
                      filledStar: Icons.build_circle,
                      unfilledStar: Icons.build_circle_outlined,
                      onChanged: (v) {
                        mservice.skill = v;
                        controller.mechanic.refresh();
                      }
                    )),
                    subtitle: Center(child: Text('competence')),

                  )
                ]
              )
            );
          }).toList()
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }
}

class MechanicServicesTab extends StatefulWidget
{
  final AccountMechanicController controller = Get.find();
  
  _MechanicServicesTabState createState() => _MechanicServicesTabState();
}

class _MechanicServicesTabState extends State<MechanicServicesTab>
{
  void initState() {
    super.initState();
    print('_MechanicServicesTabState.initState');
  }

  void submit() async {
    await widget.controller.submit();
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          MechanicServicesForm(controller: widget.controller),
          RaisedButton(
            onPressed: () {
              widget.controller.mechanic.value.services.add(MechanicSkill());
              widget.controller.mechanic.refresh();
            },
            child: Text('add')
          ),
          RaisedButton(onPressed: () => submit(), child: Text('save'))
        ]
      )
    );
  }
}

class MechanicInfoTab extends StatefulWidget
{
  final AccountMechanicController controller = Get.find();

  _MechanicInfoTabState createState() => _MechanicInfoTabState();
}

class _MechanicInfoTabState extends State<MechanicInfoTab>
{
  TextEditingController _aboutController;

  final _formKey = GlobalKey<FormState>();
  StreamSubscription _stream;

  void initState() {
    print('_MechanicInfoTabState.initState');
    super.initState();
    _aboutController = TextEditingController();

    _stream = widget.controller.mechanic.listen((m) { 
      _aboutController.text = m.about;
    });
  }

  void dispose() {
    _stream.cancel();
    super.dispose();
  }

  void submit() async {
    if (_formKey.currentState.validate()) {
      widget.controller.mechanic.value.about = _aboutController.text;
      await widget.controller.submit();
    }
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
        children: [
          TextFormField(
            controller: _aboutController,
            decoration: InputDecoration(
              icon: Icon(Icons.lock), 
              labelText: 'About', 
              hintText: 'about'
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'input.required';
              }
              return null;
            },
          ),
          RaisedButton(onPressed: () => submit(), child: Text('save'))
        ]
      ))
    );
  }
}

class CustomerProfilePage extends StatefulWidget
{
  _CustomerProfilePageState createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage>
{
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car)),
              Tab(icon: Icon(Icons.directions_transit)),
              Tab(icon: Icon(Icons.directions_bike)),
            ],
          ),
          title: Text('Mechanic Account'),
        ),
        body: TabBarView(
          children: [
            Icon(Icons.directions_car),
            Icon(Icons.directions_transit),
            Icon(Icons.directions_bike),
          ],
        ),
      ),
    );
  }
}
