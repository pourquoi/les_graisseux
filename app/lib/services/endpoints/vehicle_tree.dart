import 'package:app/models/vehicle_tree.dart';
import 'package:app/services/crud.dart';

class VehicleTreeQueryParameters extends PaginatedQueryParameters {
  String level;

  VehicleTreeQueryParameters({this.level, String q, int page, int itemsPerPage}) : super(q: q, page: page, itemsPerPage: itemsPerPage);

  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({
      'level': level
    })..removeWhere((key, value) => value == null);
  }
}

class VehicleTreeService extends CrudService<VehicleTree> {
  VehicleTreeService() : super(resource: 'vehicles', fromJson: (data) => VehicleTree.fromJson(data), toJson: (vehicle) => vehicle.toJson());
}
