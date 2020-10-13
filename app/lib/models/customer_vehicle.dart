import 'package:app/models/common.dart';
import 'package:app/models/customer.dart';
import 'package:app/models/vehicle_tree.dart';

class CustomerVehicle extends HydraResource {
  int id;
  Customer customer;
  VehicleTree type;

  CustomerVehicle({this.id, this.customer, this.type});

  CustomerVehicle.fromJson(Map<String, dynamic> json,
      {Map<String, dynamic> context}) {
    if (context == null) context = initContext();

    id = json['id'];

    context[CTX_MAP_BY_IDS][json['@id']] = this;

    if (json.containsKey('customer') && json['customer'] != null) {
      if (json['customer'] is String) {
        customer = context[CTX_MAP_BY_IDS].containsKey(json['customer'])
            ? context[CTX_MAP_BY_IDS][json['customer']]
            : null;
      } else {
        customer = Customer.fromJson(json['customer'], context: context);
      }
    }

    if (json.containsKey('type') && json['type'] != null) {
      if (json['type'] is String) {
        customer = context[CTX_MAP_BY_IDS].containsKey(json['type'])
            ? context[CTX_MAP_BY_IDS][json['type']]
            : null;
      } else {
        type = VehicleTree.fromJson(json['type'], context: context);
      }
    }
  }
}
