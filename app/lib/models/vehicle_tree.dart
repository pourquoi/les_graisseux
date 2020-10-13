import 'package:app/models/common.dart';

class VehicleTree extends HydraResource {
  int id;
  String level;
  String name;

  VehicleTree parent;
  List<VehicleTree> children;

  VehicleTree({this.id, this.level, this.name});

  VehicleTree.fromJson(Map<String, dynamic> json,
      {Map<String, dynamic> context}) {
    if (context == null) context = initContext();

    id = json['id'];
    level = json['level'];
    name = json['name'];

    context[CTX_MAP_BY_IDS][json['@id']] = this;

    if (json.containsKey('parent') && json['parent'] != null) {
      if (json['parent'] is String) {
        parent = context[CTX_MAP_BY_IDS].containsKey(json['parent'])
            ? context[CTX_MAP_BY_IDS][json['parent']]
            : null;
      } else {
        parent = VehicleTree.fromJson(json['parent'], context: context);
      }
    }

    if (json.containsKey('children') && json['children'] != null) {
      children = json['children']
          .toList()
          .map((v) {
            if (v is String) {
              return context[CTX_MAP_BY_IDS].containsKey(v)
                  ? context[CTX_MAP_BY_IDS][v]
                  : null;
            } else {
              return VehicleTree.fromJson(v, context: context);
            }
          })
          .where((v) => v != null)
          .toList()
          .cast<VehicleTree>();
    }
  }
}
