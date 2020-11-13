import 'package:app/models/common.dart';
import 'package:app/models/job_application.dart';
import 'package:app/models/user.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends HydraResource
{
  int id;
  String uuid;
  DateTime createdAt;
  List<ChatUser> users = List<ChatUser>();
  JobApplication application;
  ChatMessage lastMessage;

  ChatRoom({this.id, this.uuid, this.users}) {
    if (uuid == null) uuid = Uuid().v4();
  }

  ChatRoom.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) { 
    parseJson(json, context: context); 
  }

  ChatUser getUser(int currentUserId) {
    return users.firstWhere((u) => u.user.id == currentUserId);
  }

  ChatUser getInterlocutor(int currentUserId) {
    try {
    return users.firstWhere((u) => u.user.id != currentUserId);
    } catch(_) { return null; }
  }

  void parseJson(Map<String, dynamic> json,
      {Map<String, dynamic> context}) {
    if (context == null) context = initContext();
    super.parseJson(json, context: context);

    context[CTX_MAP_BY_IDS][json['@id']] = this;

    id = json['id'];
    uuid = json['uuid'];
    createdAt = DateTime.parse(json['created_at']);

    if (json.containsKey('users') && json['users'] != null) {
      users = json['users']
          .toList()
          .map((v) {
            if (v is String) {
              return context[CTX_MAP_BY_IDS].containsKey(v)
                  ? context[CTX_MAP_BY_IDS][v]
                  : null;
            } else {
              return ChatUser.fromJson(v, context: context);
            }
          })
          .where((v) => v != null)
          .toList()
          .cast<ChatUser>();
    }

    if (json.containsKey('application') && json['application'] != null) {
      if (json['application'] is String) {
        application = context[CTX_MAP_BY_IDS].containsKey(json['application'])
            ? context[CTX_MAP_BY_IDS][json['application']]
            : null;
      } else {
        application = JobApplication.fromJson(json['application'], context: context);
      }
    }

    if (json.containsKey('last_message') && json['last_message'] != null) {
      if (json['last_message'] is String) {
        lastMessage = context[CTX_MAP_BY_IDS].containsKey(json['last_message'])
            ? context[CTX_MAP_BY_IDS][json['last_message']]
            : null;
      } else {
        lastMessage = ChatMessage.fromJson(json['last_message'], context: context);
      }
    }
  }

  Map<String, dynamic> toJson({Map<String, dynamic> context}) {
    Map<String, dynamic> data = {};

    return data..addAll(super.toJson(context: context));
  }
}

class ChatUser extends HydraResource
{
  int id;
  User user;

  ChatUser({this.id, this.user});

  ChatUser.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) { 
    parseJson(json, context: context); 
  }

  void parseJson(Map<String, dynamic> json,
      {Map<String, dynamic> context}) {
    if (context == null) context = initContext();
    super.parseJson(json, context: context);

    id = json['id'];

    if (json.containsKey('user') && json['user'] != null) {
      if (json['user'] is String) {
        user = context[CTX_MAP_BY_IDS].containsKey(json['user'])
            ? context[CTX_MAP_BY_IDS][json['user']]
            : null;
      } else {
        user = User.fromJson(json['user'], context: context);
      }
    }
  }

  Map<String, dynamic> toJson({Map<String, dynamic> context}) {
    Map<String, dynamic> data = {};

    return data..addAll(super.toJson(context: context));
  }
}

class ChatMessage extends HydraResource
{
  int id;
  ChatUser user;
  ChatRoom room;
  String message;
  DateTime createdAt;

  ChatMessage();

  ChatMessage.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) { 
    parseJson(json, context: context); 
  }

  String get date {
    if (createdAt != null) {
      return DateFormat('dd MMM – kk:mm').format(createdAt);
    }
    return '-';
  }

  void parseJson(Map<String, dynamic> json,
      {Map<String, dynamic> context}) {
    if (context == null) context = initContext();
    super.parseJson(json, context: context);

    id = json['id'];
    message = json['message'];
    createdAt = DateTime.parse(json['created_at']);

    context[CTX_MAP_BY_IDS][json['@id']] = this;

    if (json.containsKey('user') && json['user'] != null) {
      if (json['user'] is String) {
        user = context[CTX_MAP_BY_IDS].containsKey(json['user'])
            ? context[CTX_MAP_BY_IDS][json['user']]
            : null;
      } else {
        user = ChatUser.fromJson(json['user'], context: context);
      }
    }

    if (json.containsKey('room') && json['room'] != null) {
      if (json['room'] is String) {
        room = context[CTX_MAP_BY_IDS].containsKey(json['room'])
            ? context[CTX_MAP_BY_IDS][json['room']]
            : null;
      } else {
        room = ChatRoom.fromJson(json['room'], context: context);
      }
    }
  }

  Map<String, dynamic> toJson({Map<String, dynamic> context}) {
    Map<String, dynamic> data = {
      'message': message,
      'room': room.hydraId
    };

    return data..addAll(super.toJson(context: context));
  }
}