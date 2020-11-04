import 'package:app/models/chat.dart';
import 'package:app/models/common.dart';
import 'package:app/models/job.dart';
import 'package:app/models/mechanic.dart';

class JobApplication extends HydraResource {
  int id;
  DateTime createdAt;
  Job job;
  Mechanic mechanic;
  ChatRoom chat;

  JobApplication({this.id, this.mechanic, this.job});

  JobApplication.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) { 
    parseJson(json, context: context); 
  }

  void parseJson(Map<String, dynamic> json, {Map<String, dynamic> context}) {
    if (context == null) context = initContext();
    super.parseJson(json, context: context);

    id = json['id'];
    createdAt = DateTime.parse(json['created_at']);

    context[CTX_MAP_BY_IDS][json['@id']] = this;

    if (json.containsKey('job') && json['job'] != null) {
      if (json['job'] is String) {
        job = context[CTX_MAP_BY_IDS].containsKey(json['job'])
            ? context[CTX_MAP_BY_IDS][json['job']]
            : null;
      } else {
        job = Job.fromJson(json['job'], context: context);
      }
    }

    if (json.containsKey('mechanic') && json['mechanic'] != null) {
      if (json['mechanic'] is String) {
        mechanic = context[CTX_MAP_BY_IDS].containsKey(json['mechanic'])
            ? context[CTX_MAP_BY_IDS][json['mechanic']]
            : null;
      } else {
        mechanic = Mechanic.fromJson(json['mechanic'], context: context);
      }
    }

    if (json.containsKey('chat') && json['chat'] != null) {
      if (json['mechanic'] is String) {
        chat = context[CTX_MAP_BY_IDS].containsKey(json['chat'])
            ? context[CTX_MAP_BY_IDS][json['chat']]
            : null;
      } else {
        chat = ChatRoom.fromJson(json['chat'], context: context);
      }
    }
  }
}
