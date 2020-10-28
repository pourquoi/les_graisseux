import 'package:app/models/common.dart';
import 'package:app/models/service_tree.dart';
import 'package:app/models/user.dart';
import 'package:app/models/vehicle_tree.dart';

class Mechanic extends HydraResource {
  int id;
  User user;
  String about;
  List<MechanicSkill> services = List<MechanicSkill>();

  Mechanic({this.id, this.user});

  Mechanic.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) { 
    parseJson(json, context: context);
  }

  void parseJson(Map<String, dynamic> json,
      {Map<String, dynamic> context}) {
    if (context == null) context = initContext();
    super.parseJson(json, context: context);

    id = json['id'];
    about = json['about'];

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

    if (json.containsKey('services') && json['services'] != null) {
      services = json['services']
          .toList()
          .map((v) {
            if (v is String) {
              return context[CTX_MAP_BY_IDS].containsKey(v)
                  ? context[CTX_MAP_BY_IDS][v]
                  : null;
            } else {
              return MechanicSkill.fromJson(v, context: context);
            }
          })
          .where((v) => v != null)
          .toList()
          .cast<MechanicSkill>();
    }
  }

  Map<String, dynamic> toJson({Map<String, dynamic> context}) {
    Map<String, dynamic> data = {
      'id': id,
      'about': about,
      'services': services.map((s) => s.toJson(context: context)).toList()
    };

    if (user != null) {
      data['user'] = user.hydraId;
    }

    return data..addAll(super.toJson(context: context));
  }
}

class MechanicSkill extends HydraResource
{
  int id;
  int skill;
  Mechanic mechanic;
  VehicleTree vehicle;
  ServiceTree service;

  MechanicSkill();

  MechanicSkill.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) { 
    parseJson(json, context: context);
  }

  void parseJson(Map<String, dynamic> json,
      {Map<String, dynamic> context}) {
    if (context == null) context = initContext();
    super.parseJson(json, context: context);

    id = json['id'];
    skill = json['skill'];

    if (json.containsKey('mechanic') && json['mechanic'] != null) {
      if (json['mechanic'] is String) {
        mechanic = context[CTX_MAP_BY_IDS].containsKey(json['mechanic'])
            ? context[CTX_MAP_BY_IDS][json['mechanic']]
            : null;
      } else {
        mechanic = Mechanic.fromJson(json['mechanic'], context: context);
      }
    }

    if (json.containsKey('vehicle') && json['vehicle'] != null) {
      if (json['user'] is String) {
        vehicle = context[CTX_MAP_BY_IDS].containsKey(json['vehicle'])
            ? context[CTX_MAP_BY_IDS][json['vehicle']]
            : null;
      } else {
        vehicle = VehicleTree.fromJson(json['vehicle'], context: context);
      }
    }

    if (json.containsKey('service') && json['service'] != null) {
      if (json['service'] is String) {
        service = context[CTX_MAP_BY_IDS].containsKey(json['service'])
            ? context[CTX_MAP_BY_IDS][json['service']]
            : null;
      } else {
        service = ServiceTree.fromJson(json['service'], context: context);
      }
    }
  }

  Map<String, dynamic> toJson({Map<String, dynamic> context}) {
    Map<String, dynamic> data = {
      'id': id,
      'skill': skill
    };

    if (vehicle != null) {
      data['vehicle'] = vehicle.hydraId;
    }

    if (service != null) {
      data['service'] = service.hydraId;
    }

    if (mechanic != null) {
      data['mechanic'] = mechanic.hydraId;
    }

    return data..addAll(super.toJson(context: context));
  }
}