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
    return Scaffold(
      appBar: AppBar(title: Text('Account')),
      drawer: AppDrawer(),
      body: SafeArea(child: Obx(() {
        if (widget.appController.profileType.value == ProfileType.Customer) {
          return CustomerProfilePage();
        } else {
          return MechanicProfilePage();
        }
      }))
    );
  }
}

class MechanicProfilePage extends StatefulWidget
{
  final AccountMechanicController controller = Get.find();

  _MechanicProfilePageState createState() => _MechanicProfilePageState();
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
            return Row(
              children: [
                Column(
                  children: [
                    Row(children: [
                      RaisedButton(
                        onPressed: () async {
                          ServiceTree service = await Get.to(ServicePicker());
                          if (service != null) {
                            mservice.service = service;
                            controller.mechanic.refresh();
                          }
                        },
                        child: Text(mservice.service != null ? mservice.service.label : 'pick')
                      ),
                    ]),
                    
                    Row(children: [
                      RaisedButton(
                        onPressed: () async {
                          VehicleTree vehicle = await Get.to(VehiclePicker());
                          if (vehicle != null) {
                            mservice.vehicle = vehicle;
                            controller.mechanic.refresh();
                          }
                        },
                        child: Text(mservice.vehicle != null ? mservice.vehicle.name : 'pick')
                      ),
                    ]),

                    Row(children: [
                      StarRating(
                        value: mservice.skill,
                        filledStar: Icons.build_circle,
                        unfilledStar: Icons.build_circle_outlined,
                        onChanged: (v) {
                          print(v);
                          mservice.skill = v;
                          controller.mechanic.refresh();
                        },)
                    ]),
                  ]
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    controller.mechanic.value.services.remove(mservice);
                    controller.mechanic.refresh();
                  }
                )
              ]
            );
          }).toList()
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }
}

class _MechanicProfilePageState extends State<MechanicProfilePage>
{
  TextEditingController _aboutController;

  final _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    _aboutController = TextEditingController();
    widget.controller.load().then((_) {
      _aboutController.text = widget.controller.mechanic.value.about;
    });
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
          MechanicServicesForm(controller: widget.controller),
          RaisedButton(
            onPressed: () {
              widget.controller.mechanic.value.services.add(MechanicSkill());
              widget.controller.mechanic.refresh();
            },
            child: Text('add')
          ),
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
    return SizedBox.shrink();
  }
}
