import 'package:app/models/common.dart';

class ServiceTree extends HydraResource {
  int id;
  String label;
  String description;

  ServiceTree parent;
  ServiceTree root;
  List<ServiceTree> children;

  ServiceTree({this.id, this.label, this.description});

  ServiceTree.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) {
    parseJson(json, context: context);
  }

  void parseJson(Map<String, dynamic> json,
      {Map<String, dynamic> context}) {
    if (context == null) context = initContext();
    super.parseJson(json, context: context);

    id = json['id'];
    label = json['label'];
    description = json['description'];

    context[CTX_MAP_BY_IDS][json['@id']] = this;

    if (json.containsKey('parent') && json['parent'] != null) {
      if (json['parent'] is String) {
        parent = context[CTX_MAP_BY_IDS].containsKey(json['parent'])
            ? context[CTX_MAP_BY_IDS][json['parent']]
            : null;
      } else {
        parent = ServiceTree.fromJson(json['parent'], context: context);
      }
    }

    if (json.containsKey('root') && json['root'] != null) {
      if (json['root'] is String) {
        root = context[CTX_MAP_BY_IDS].containsKey(json['root'])
            ? context[CTX_MAP_BY_IDS][json['root']]
            : null;
      } else {
        root = ServiceTree.fromJson(json['root'], context: context);
      }
    }
  }
}
