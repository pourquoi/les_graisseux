import 'package:app/models/common.dart';

enum ProfileType { Undefined, Mechanic, Customer, Both }

class User extends HydraResource {
  int id;
  String email;
  String password;
  String username;

  User({this.id, this.email, this.username});

  User.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) {
    id = json['id'];
    email = json['email'];
    username = json['username'];
  }

  Map<String, dynamic> toJson({Map<String, dynamic> context}) {
    return {'email': email, 'username': username};
  }
}
