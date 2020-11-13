import 'dart:async';

import 'package:app/controllers/account/applications.dart';
import 'package:app/controllers/mechanic.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/job_application.dart';
import 'package:app/models/mechanic.dart';
import 'package:app/services/crud_service.dart';
import 'package:app/services/endpoints/job.dart';
import 'package:app/widgets/ui/drawer.dart';
import 'package:app/widgets/ui/profile_picture.dart';
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
import 'package:app/routes.dart' as routes;

class ProfilePage extends StatefulWidget
{
  final AppController appController = Get.find();

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
  final AppController appController = Get.find();
  final AccountMechanicController controller = Get.find();
  final JobApplicationsController jobApplicationsController = Get.put(JobApplicationsController());

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
          actions: [
            IconButton(
              icon: Icon(Icons.switch_account) ,
              onPressed: () {
                widget.appController.toggleProfile();
              }
            )
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car)),
              Tab(icon: Icon(Icons.directions_transit)),
              Tab(icon: Icon(Icons.directions_bike)),
            ],
          ),
          title: Text('Mechanic Account'),
        ),
        body: 
            TabBarView(
              children: [
                MechanicInfoTab(),
                MechanicServicesTab(),
                MechanicApplicationsPage()
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
          ProfilePictureWidget(),
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

class MechanicApplicationsPage extends StatefulWidget
{
  final JobApplicationsController controller = Get.find();
  _MechanicApplicationsState createState() => _MechanicApplicationsState();
}

class _MechanicApplicationsState extends State<MechanicApplicationsPage>
{
  JobApplicationQueryParameters params;
  PaginatedQueryResponse<JobApplication> applications;

  void initState() {
    super.initState();
    print('_MechanicApplicationsState.initState');
    widget.controller.load();
  }

  Widget build(_) {
    return Obx(() {
      return ListView.builder(
        itemCount: widget.controller.items.length + 1,
        itemBuilder: (_, idx) {
          if (idx < widget.controller.items.length) {
            return Card(
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(routes.job.replaceFirst(':job', widget.controller.items[idx].job.id.toString()));
                },
                child: Column(
                  children: [
                    Text('${widget.controller.items[idx].id}'),
                    Text('${widget.controller.items[idx].job.title}')
                  ]
                )
              )
            );
          } else if (idx == widget.controller.items.length) {
            if (widget.controller.pagination.value.next != null) {
              widget.controller.more();
              return Center(child:CircularProgressIndicator());
            } else {
              return Container(
                color: Colors.blueGrey,
                child: Center(child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('end of results'.toUpperCase(), style: TextStyle(color: Colors.grey, fontSize: 10))
                ))
              );
            }
          } else {
            return Container();
          }
        },
      );
    });
  }
}

class CustomerProfilePage extends StatefulWidget
{
  final AppController appController = Get.find();
  _CustomerProfilePageState createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage>
{
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.switch_account) ,
              onPressed: () {
                widget.appController.toggleProfile();
              }
            )
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car)),
              Tab(icon: Icon(Icons.directions_transit)),
              Tab(icon: Icon(Icons.directions_bike)),
            ],
          ),
          title: Text('Customer Account'),
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
