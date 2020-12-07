import 'package:app/controllers/job.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/address.dart';
import 'package:app/models/job.dart';
import 'package:app/models/job_application.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/login.dart';
import 'package:app/services/endpoints/job.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:app/routes.dart' as routes;

class JobPage extends StatelessWidget
{
  final UserController userController = Get.find();
  final JobApplicationService jobApplicationService = Get.find();
  final JobController controller = Get.put(JobController());

  JobPage({Key key}) : super(key: key) {
    print('JobPage.construct');
    if (Get.parameters['job'] != null) {
      controller.load(int.parse(Get.parameters['job']));
    } else if(controller.job.value.id != null) {
      controller.load(controller.job.value.id);
    }
  }

  Future apply() async {
    Job job = controller.job.value;
    User user = userController.user.value;
    if (userController.loggedIn.value && user.mechanic != null) {
      if (job.application != null) {
        JobApplication app = await jobApplicationService.get(job.application.id);
        if (app.chat != null) {
          Get.toNamed(routes.chat_room.replaceFirst(':chat', app.chat.uuid));
        }
      } else {
        JobApplication app = await controller.apply();
        if (app.chat != null) {
          Get.toNamed(routes.chat_room.replaceFirst(':chat', app.chat.uuid));
        }
      }
    } else {
      Get.to(LoginPage(isModal: true));
    }
  }

  Future comment() async {
    Job job = controller.job.value;
    if (userController.loggedIn.value) {
      Get.toNamed(routes.chat_room.replaceFirst(':chat', job.chat.uuid));
    } else {
      Get.to(LoginPage(isModal: true));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => controller.job.value.id == null || controller.loading.value ? Text('...') : Text(controller.job.value.title)),
        actions: [
          
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Obx(() => controller.job.value.id != null ? Column(
          children: [
            buildHeader(context),
            buildBody(context),
            buildUser(context),
            buildComment(context)
          ],
        ) : Center(child:CircularProgressIndicator())))
      )
    );
  }

  Widget buildHeader(BuildContext context) {
    Job job = controller.job.value;
    if (job.pictures.length > 0) {

      return Container(
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(job.pictures[0].url),
            fit: BoxFit.cover
          )
        )
      );
    
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildApply(BuildContext context) {
    Job job = controller.job.value;
    User user = userController.user.value;

    return OutlineButton(
      onPressed: () => apply(),
      child: Row(
        children: [
          Icon(FontAwesomeIcons.comment),
          Text('Chat')
        ],
      )
    );
  }

  Widget buildAddress(BuildContext context) {
    Address address = controller.job.value.address;
    return Row(
      children: [
        Icon(FontAwesomeIcons.mapMarkedAlt),
        Text(address.toString())
      ],
    );
  }

  Widget buildBody(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Row(
        children: [
          Flexible(child: Column(
            children: [
              Text(controller.job.value.title ?? ''),
              buildApply(context),
              Text(controller.job.value.description ?? ''),
              buildAddress(context)
            ],
          ))
        ]
      ))
    );
  }

  Widget buildUser(BuildContext context) {
    User user = controller.job.value.customer.user;
    return Padding(
      padding: EdgeInsets.all(15),
      child: Card(
      color: Colors.red,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              user.avatar != null ? CircleAvatar(
                radius: 31,
                backgroundImage: NetworkImage(user.avatar.thumbUrl),
              ) : Icon(Icons.person, size: 72),
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: Column(
                  children: [
                    Text(user.username)
                  ],
                )
              )
            ],
          )
        )
      )
    );
  }

  Widget buildComment(BuildContext context) {
    return OutlineButton(
      child: Text('Discussion'),
      onPressed: () => comment()
    );
  }
}