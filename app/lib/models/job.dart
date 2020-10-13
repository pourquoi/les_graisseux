import 'package:app/models/common.dart';
import 'package:app/models/customer.dart';
import 'package:app/models/customer_vehicle.dart';
import 'package:app/models/service_tree.dart';

class Job extends HydraResource {
  int id;
  String title;
  String description;

  Customer customer;
  List<ServiceTree> tasks;
  CustomerVehicle vehicle;

  Job({this.id, this.customer, this.vehicle});

  Job.fromJson(Map<String, dynamic> json,
      {Map<String, dynamic> context}) {
    if (context == null) context = initContext();

    id = json['id'];
    title = json['title'];
    description = json['description'];

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

    if (json.containsKey('vehicle') && json['vehicle'] != null) {
      if (json['vehicle'] is String) {
        vehicle = context[CTX_MAP_BY_IDS].containsKey(json['vehicle'])
            ? context[CTX_MAP_BY_IDS][json['vehicle']]
            : null;
      } else {
        vehicle = CustomerVehicle.fromJson(json['vehicle'], context: context);
      }
    }

    if (json.containsKey('tasks') && json['tasks'] != null) {
      tasks = json['tasks']
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
