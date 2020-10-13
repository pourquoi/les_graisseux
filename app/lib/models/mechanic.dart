import 'package:app/models/common.dart';
import 'package:app/models/service_tree.dart';
import 'package:app/models/user.dart';

class Mechanic extends HydraResource {
  int id;
  User user;
  List<ServiceTree> services;

  Mechanic({this.id, this.user});

  Mechanic.fromJson(Map<String, dynamic> json,
      {Map<String, dynamic> context}) {
    if (context == null) context = initContext();

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

    if (json.containsKey('services') && json['services'] != null) {
      services = json['services']
          .toList()
          .map((v) {
            if (v is String) {
              return context[CTX_MAP_BY_IDS].containsKey(v)
                  ? context[CTX_MAP_BY_IDS][v]
                  : null;
            } else {
              return ServiceTree.fromJson(v, context: context);
            }
          })
          .where((v) => v != null)
          .toList()
          .cast<ServiceTree>();
    }

  }
}
