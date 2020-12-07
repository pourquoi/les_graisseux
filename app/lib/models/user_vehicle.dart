import 'package:app/models/common.dart';
import 'package:app/models/user.dart';
import 'package:app/models/vehicle_tree.dart';

class UserVehicle extends HydraResource {
  int id;

  int km;
  User user;
  VehicleTree type;

  UserVehicle({this.id, this.user, this.type});

  UserVehicle.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) { 
    parseJson(json, context: context); 
  }

  void parseJson(Map<String, dynamic> json, {Map<String, dynamic> context}) {
    if (context == null) context = initContext();
    super.parseJson(json, context: context);

    id = json['id'];

    context[CTX_MAP_BY_IDS][json['@id']] = this;

    if (json.containsKey('user') && json['user'] != null) {
      if (json['user'] is String) {
        user = context[CTX_MAP_BY_IDS].containsKey(json['user'])
            ? context[CTX_MAP_BY_IDS][json['user']]
            : null;
      } else {
        user = User.fromJson(json['user'], context: context);
      }
    }

    if (json.containsKey('type') && json['type'] != null) {
      if (json['type'] is String) {
        type = context[CTX_MAP_BY_IDS].containsKey(json['type'])
            ? context[CTX_MAP_BY_IDS][json['type']]
            : null;
      } else {
        type = VehicleTree.fromJson(json['type'], context: context);
      }
    }
  }

  Map<String, dynamic> toJson({Map<String, dynamic> context}) {
    Map<String, dynamic> data = {
      'km': km
    };
    
    if (user != null) {
      data['user'] = user.hydraId;
    }
    if (type != null) {
      data['type'] = type.hydraId;
    }

    return data..addAll(super.toJson(context: context));
  }
}
