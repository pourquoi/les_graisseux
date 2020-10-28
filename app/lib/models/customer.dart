import 'package:app/models/common.dart';
import 'package:app/models/job.dart';
import 'package:app/models/user.dart';

class Customer extends HydraResource {
  int id;
  User user;
  List<Job> jobs;

  Customer({this.id, this.user});

  Customer.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) {
    parseJson(json, context: context); 
  }

  void parseJson(Map<String, dynamic> json,
      {Map<String, dynamic> context}) {
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

    if (json.containsKey('jobs') && json['jobs'] != null) {
      jobs = json['jobs']
          .toList()
          .map((v) {
            if (v is String) {
              return context[CTX_MAP_BY_IDS].containsKey(v)
                  ? context[CTX_MAP_BY_IDS][v]
                  : null;
            } else {
              return Job.fromJson(v, context: context);
            }
          })
          .where((v) => v != null)
          .toList()
          .cast<Job>();
    }
  }
}
