import 'package:app/models/common.dart';
import 'package:app/models/customer.dart';
import 'package:app/services/crud_service.dart';

class CustomerService extends CrudService<Customer> {
  CustomerService() : super(resource: 'customers', fromJson: (data) => Customer.fromJson(data), toJson: (customer) => customer.toJson());
}
