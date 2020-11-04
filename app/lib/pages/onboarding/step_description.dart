
import 'package:app/controllers/account/job.dart';
import 'package:app/controllers/account/mechanic.dart';
import 'package:app/controllers/onboarding.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepDescription extends StatefulWidget {
  final OnboardingController controller = Get.find();
  final UserController userController = Get.find();
  final AccountJobController jobController = Get.find();
  final AccountMechanicController mechanicController = Get.find();

  StepDescription({Key key}) : super(key: key);

  _StepDescriptionState createState() => _StepDescriptionState();
}

class _StepDescriptionState extends State<StepDescription>
{
  TextEditingController _titleController;
  TextEditingController _descriptionController;

  final _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();

    if (widget.controller.profileType.value == ProfileType.Customer) {
      _titleController = TextEditingController(text: widget.jobController.job.value.title ?? '');
      _descriptionController = TextEditingController(text: widget.jobController.job.value.description ?? '');
    } else {
      _descriptionController = TextEditingController(text: widget.mechanicController.mechanic.value.about ?? '');
    }
  }

  void dispose() {
    if (_titleController != null)
      _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void submit() {
    if (_formKey.currentState.validate()) {
      if (widget.controller.profileType.value == ProfileType.Customer) {
        widget.jobController.job.value.title = _titleController.text;
        widget.jobController.job.value.description = _descriptionController.text;
      } else {
        widget.mechanicController.mechanic.value.about = _descriptionController.text;
      }
      widget.controller.submit();
    }
  }

  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Obx(() => widget.controller.profileType.value == ProfileType.Customer ?
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                icon: Icon(Icons.lock), 
                labelText: 'Title', 
                hintText: 'title'
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'input.required';
                }
                return null;
              },
            ) : SizedBox.shrink()),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              icon: Icon(Icons.lock), 
              labelText: 'Description', 
              hintText: 'description'
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'input.required';
              }
              return null;
            },
          ),
          RaisedButton(
            onPressed: () => submit(),
            child: Text('Ok')
          )
        ],
      )
    );
  }
}
