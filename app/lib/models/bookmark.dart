import 'package:app/models/common.dart';
import 'package:app/models/job.dart';
import 'package:app/models/user.dart';
import 'package:app/models/user_vehicle.dart';


class Bookmark extends HydraResource
{
  int id;

  User user;
  UserVehicle vehicle;
  Job job;

  Bookmark({this.user, this.vehicle, this.job});

  Bookmark.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) { 
    parseJson(json, context: context); 
  }

  void parseJson(Map<String, dynamic> json, {Map<String, dynamic> context}) {
    if (context == null) context = initContext();
    super.parseJson(json, context: context);

    id = json['id'];

    if (json.containsKey('bookmarked_user') && json['bookmarked_user'] != null) {
      if (json['bookmarked_user'] is String) {
        user = context[CTX_MAP_BY_IDS].containsKey(json['bookmarked_user'])
            ? context[CTX_MAP_BY_IDS][json['bookmarked_user']]
            : null;
      } else {
        user = User.fromJson(json['bookmarked_user'], context: context);
      }
    }

    if (json.containsKey('bookmarked_job') && json['bookmarked_job'] != null) {
      if (json['user'] is String) {
        job = context[CTX_MAP_BY_IDS].containsKey(json['bookmarked_job'])
            ? context[CTX_MAP_BY_IDS][json['bookmarked_job']]
            : null;
      } else {
        job = Job.fromJson(json['bookmarked_job'], context: context);
      }
    }

    if (json.containsKey('bookmarked_vehicle') && json['bookmarked_vehicle'] != null) {
      if (json['bookmarked_vehicle'] is String) {
        vehicle = context[CTX_MAP_BY_IDS].containsKey(json['bookmarked_vehicle'])
            ? context[CTX_MAP_BY_IDS][json['bookmarked_vehicle']]
            : null;
      } else {
        vehicle = UserVehicle.fromJson(json['bookmarked_vehicle'], context: context);
      }
    }
  }

  Map<String, dynamic> toJson({Map<String, dynamic> context}) {
    Map<String, dynamic> data = {};

    if (user != null) data['user'] = user.hydraId;
    if (job != null) data['job'] = user.hydraId;
    if (vehicle != null) data['vehicle'] = user.hydraId;

    return data..addAll(super.toJson(context: context));
  }
}