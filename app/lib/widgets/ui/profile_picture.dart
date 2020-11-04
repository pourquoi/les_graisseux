import 'dart:io';

import 'package:app/controllers/user.dart';
import 'package:app/models/media.dart';
import 'package:app/services/endpoints/media.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/routes.dart' as routes;

class ProfilePictureWidget extends StatefulWidget
{
  final MediaService mediaService = Get.put(MediaService());
  final UserController userController = Get.find();
  
  _ProfilePictureState createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePictureWidget>
{
  void initState() {
    super.initState();
  }

  void edit() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File _image = File(pickedFile.path);

      Media avatar = await widget.mediaService.uploadFile(_image);
      await widget.userController.editAvatar(avatar);
    }
  }

  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column( 
        children: [Obx(() {
        if (widget.userController.status.value == UserStatus.loggedin) {
          return Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green
                ),
                child: Obx(() {
                  if (widget.userController.user.value.avatar != null) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(widget.userController.user.value.avatar.url)
                    );
                  } else {
                    return Icon(Icons.person, size: 52);
                  }
                })
              ),
              Positioned(
                bottom: -15,
                right: -15,
                child: Container(
                  color: Colors.transparent,
                  child: IconButton(
                    iconSize: 20,
                    icon: Icon(Icons.edit, color: Colors.white), 
                    onPressed: () => edit()
                  )
                )
              )
            ],
          );
        } else {
          return IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Get.toNamed(routes.login);
            },
          );
        }
      })])
    );

  }
}