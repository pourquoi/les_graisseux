import 'package:app/models/common.dart';

const VehicleTreeLevel = { 
  "brand": "brand", 
  "family": "family", 
  "model": "model", 
  "type": "type" 
};

class VehicleTree extends HydraResource {
  int id;
  String level;
  String name;
  String thumbUrl;

  VehicleTree parent;
  List<VehicleTree> children;

  VehicleTree({this.id, this.level, this.name});

  VehicleTree.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) {
    parseJson(json, context:context);
  }

  String get fullName {
    String _name = name ?? '';
    if (parent != null) _name = parent.fullName + ' ' + _name;
    return _name;
  }

  String get logo {
    if (thumbUrl != null) return thumbUrl;
    if (parent != null) return parent.logo;
    return null;
  }

  void parseJson(Map<String, dynamic> json, {Map<String, dynamic> context}) {
    if (context == null) context = initContext();
    super.parseJson(json, context:context);

    id = json['id'];
    level = json['level'];
    name = json['name'];
    thumbUrl = json['logo_thumb_url'];

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
