import 'package:app/models/vehicle_tree.dart';
import 'package:app/services/crud_service.dart';

enum VehicleTreeLevel { brand, family, model, type }

class VehicleTreeQueryParameters extends PaginatedQueryParameters {
  String level;

  VehicleTreeQueryParameters({this.level, String q, int page, int itemsPerPage}) : super(q: q, page: page, itemsPerPage: itemsPerPage);

  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({
      'name': q,
      'level': level == '' ? null : level
    });
  }
}

class VehicleTreeService extends CrudService<VehicleTree> {
  VehicleTreeService() : super(resource: 'vehicles', fromJson: (data) => VehicleTree.fromJson(data), toJson: (vehicle) => vehicle.toJson());
}
