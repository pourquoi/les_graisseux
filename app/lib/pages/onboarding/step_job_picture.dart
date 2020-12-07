import 'dart:io';

import 'package:app/controllers/account/job.dart';
import 'package:app/controllers/job.dart';
import 'package:app/controllers/onboarding.dart';
import 'package:app/models/media.dart';
import 'package:app/services/endpoints/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class StepJobPicture extends StatefulWidget {
  final MediaService mediaService = Get.put(MediaService());
  final OnboardingController controller = Get.find();
  final AccountJobController jobController = Get.find();
  
  StepJobPicture({Key key}) : super(key: key);

  @override
  _StepJobPictureState createState() => _StepJobPictureState();
}

class _StepJobPictureState extends State<StepJobPicture> {
  bool uploading = false;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 32),
        Obx( () => (widget.jobController.job.value.pictures.length > 0) ?
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.jobController.job.value.pictures[0].thumbUrl),
                fit: BoxFit.cover
              )
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      widget.jobController.job.value.pictures.removeAt(0);
                      widget.jobController.job.refresh();
                    },
                  ),
                )
              ],
            )
          ) :
          OutlineButton(
            child: Text('Add picture'),
            onPressed: () async {
              final picker = ImagePicker();
              final pickedFile = await picker.getImage(source: ImageSource.camera);

              if (pickedFile != null) {
                File _image = File(pickedFile.path);

                setState(() { 
                  uploading = true;
                });

                Media picture = await widget.mediaService.uploadFile(_image);
                widget.jobController.job.value.pictures.add(picture);
                widget.jobController.job.refresh();

                setState(() {
                  uploading = false;
                });
              }
            },
          )      
        ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            RaisedButton(
              onPressed: () => widget.controller.next(),
              child: Icon(Icons.navigate_next_rounded)
            ),
          ]
        )
      ],
    );
  }
}