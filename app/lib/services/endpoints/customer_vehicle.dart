import 'package:app/models/customer_vehicle.dart';
import 'package:app/services/crud_service.dart';

class CustomerVehicleService extends CrudService<CustomerVehicle> {
  CustomerVehicleService() : super(resource: 'customer_vehicles', fromJson: (data) => CustomerVehicle.fromJson(data), toJson: (vehicle) => vehicle.toJson());
}
