import 'package:app/models/address.dart';
import 'package:app/models/common.dart';
import 'package:app/models/customer.dart';
import 'package:app/models/customer_vehicle.dart';
import 'package:app/models/job_application.dart';
import 'package:app/models/service_tree.dart';

class Job extends HydraResource {
  int id;
  String title;
  String description;

  Customer customer;
  List<ServiceTree> tasks = List<ServiceTree>();
  CustomerVehicle vehicle;

  Address address;

  JobApplication application;

  Job({this.id, this.customer, this.vehicle});

  Job.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) { 
    parseJson(json, context:context); 
  }

  void addTask(ServiceTree task) {
    if (tasks.where((t) => t.id != null && t.id == task.id).isEmpty) {
      tasks.add(task);
    }
  }

  void removeTask(ServiceTree task) {
    tasks.removeWhere((t) => t.id != null && t.id == task.id);
  }

  void parseJson(Map<String, dynamic> json, {Map<String, dynamic> context}) {
    if (context == null) context = initContext();
    super.parseJson(json, context: context);

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

    if (json.containsKey('application') && json['application'] != null) {
      if (json['application'] is String) {
        application = context[CTX_MAP_BY_IDS].containsKey(json['application'])
            ? context[CTX_MAP_BY_IDS][json['application']]
            : null;
      } else {
        application = JobApplication.fromJson(json['application'], context: context);
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

    if (json.containsKey('address') && json['address'] != null) {
      address = Address.fromJson(json['address'], context: context);
    }
  }

  Map<String, dynamic> toJson({Map<String, dynamic> context}) {
    if (context == null) context = {};

    Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'description': description,
      'tasks': tasks.map((task) => task.hydraId).toList(),
      'address': address == null ? null : address.toJson(context: context)
    };

    if (customer != null) {
      data['customer'] = customer.hydraId;
    }

    if (vehicle != null) {
      data['vehicle'] = vehicle.toJson(context: context);
    }

    return data..addAll(super.toJson(context: context));
  }
}
