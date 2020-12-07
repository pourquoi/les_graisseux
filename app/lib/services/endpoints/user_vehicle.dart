import 'package:app/models/user_vehicle.dart';
import 'package:app/services/crud.dart';

class UserVehicleService extends CrudService<UserVehicle> {
  UserVehicleService() : super(resource: 'user_vehicles', fromJson: (data) => UserVehicle.fromJson(data), toJson: (vehicle) => vehicle.toJson());
}
