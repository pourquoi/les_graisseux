import 'package:app/models/vehicle_tree.dart';
import 'package:app/services/crud_service.dart';

enum VehicleTreeLevel { brand, family, model, type }

class VehicleTreeQueryParameters extends PaginatedQueryParameters {
  String level;

  VehicleTreeQueryParameters({this.level, String q, int page, int itemsPerPage}) : super(q: q, page: page, itemsPerPage: itemsPerPage);

  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({
      'level': level
    });
  }
}

class VehicleTreeService extends CrudService<VehicleTree> {
  VehicleTreeService() : super(resource: 'vehicles');

  VehicleTree fromJson(m) => VehicleTree.fromJson(m);
}
