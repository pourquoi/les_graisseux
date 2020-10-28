import 'package:app/models/address.dart';
import 'package:app/models/common.dart';
import 'package:app/models/customer.dart';
import 'package:app/models/mechanic.dart';

enum ProfileType { Undefined, Mechanic, Customer, Both }

class User extends HydraResource {
  int id;
  String email;
  String password;
  String username;

  Customer customer;
  Mechanic mechanic;

  Address address;

  User({this.id, this.email, this.username});

  User.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) {
    parseJson(json, context:context);
  }

  String toString() {
    return username;
  }

  void updateCustomer(Customer customer) {
    customer.user = this;
    this.customer = customer;
  }

  void updateMechanic(Mechanic mechanic) {
    mechanic.user = this;
    this.mechanic = mechanic;
  }

  void parseJson(Map<String, dynamic> json, {Map<String, dynamic> context}) {
    if (context == null) context = initContext();
    super.parseJson(json, context:context);

    id = json['id'];
    email = json['email'];
    username = json['username'];

    if (json.containsKey('customer') && json['customer'] != null) {
      customer = Customer.fromJson(json['customer'], context: context);
    }

    if (json.containsKey('mechanic') && json['mechanic'] != null) {
      mechanic = Mechanic.fromJson(json['mechanic'], context: context);
    }

    if (json.containsKey('address') && json['address'] != null) {
      address = Address.fromJson(json['address'], context: context);
    }
  }

  Map<String, dynamic> toJson({Map<String, dynamic> context}) {
    Map<String, dynamic> data = {
      'id': id,
      'email': email, 
      'username': username
    };

    return data..addAll(super.toJson(context: context));
  }
}
