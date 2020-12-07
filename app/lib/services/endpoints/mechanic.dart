import 'package:app/models/address.dart';
import 'package:app/models/mechanic.dart';
import 'package:app/models/service_tree.dart';
import 'package:app/models/vehicle_tree.dart';
import 'package:app/services/crud.dart';

class MechanicQueryParameters extends PaginatedQueryParameters {
  static const SORT_NEW = 'new';
  static const SORT_HOT = 'hot';
  static const SORT_DISTANCE = 'distance';

  double minRating;
  List<VehicleTree> vehicles;
  List<ServiceTree> services;
  Address address;
  int distance;

  MechanicQueryParameters({
    this.minRating, 
    this.vehicles, 
    this.services, 
    this.address, 
    this.distance, 
    String sort, String q, int page, int itemsPerPage}) : super(sort: sort, q: q, page: page, itemsPerPage: itemsPerPage);

  Map<String, dynamic> toJson() {
    var params = super.toJson();
    if (minRating != null) {
      params['rating'] = minRating;
    }
    if (vehicles != null && vehicles.length > 0) {
      params['vehicle'] = vehicles.map((v) => v.id).join(",");
    }
    if (services != null && services.length > 0) {
      params['service'] = services.map((s) => s.id).join(",");
    }
    if (address != null && distance != null && address.geolocated) {
      params['distance'] = '${address.latitude},${address.longitude},$distance';
    }
    if (sort != null) {
      params['order[$sort]'] = '';
    }
    return params;
  }
}

class MechanicService extends CrudService<Mechanic> {
  MechanicService() : super(resource: 'mechanics', fromJson: (data) => Mechanic.fromJson(data), toJson: (mechanic) => mechanic.toJson());
}
