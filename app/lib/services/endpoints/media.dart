
import 'dart:io';

import 'package:app/models/media.dart';
import 'package:app/services/crud_service.dart';
import 'package:dio/dio.dart';

class MediaService extends CrudService<Media> {
  MediaService() : super(resource: 'media_objects', fromJson: (data) => Media.fromJson(data), toJson: (media) => media.toJson());

  Future<dynamic> uploadFile(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename:fileName),
    });
    return api.post("/api/media_objects", data: formData).then((data) => fromJson(data));
  }
}