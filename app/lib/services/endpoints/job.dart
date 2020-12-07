import 'package:app/models/address.dart';
import 'package:app/models/job.dart';
import 'package:app/models/job_application.dart';
import 'package:app/models/service_tree.dart';
import 'package:app/models/vehicle_tree.dart';
import 'package:app/services/crud.dart';

class JobQueryParameters extends PaginatedQueryParameters {
  static const SORT_NEW = 'new';
  static const SORT_DISTANCE = 'distance';
  static const SORT_HOT = 'hot';

  int distance;
  dynamic user;
  Address address;
  List<VehicleTree> vehicles;
  List<ServiceTree> services;

  JobQueryParameters({
    this.address, 
    this.distance, 
    this.services, 
    this.vehicles, 
    String sort=JobQueryParameters.SORT_NEW, String q, int page, int itemsPerPage}) : super(sort: sort, q: q, page: page, itemsPerPage: itemsPerPage);

  Map<String, dynamic> toJson() {
    var params = super.toJson();
    if (address != null && distance != null && address.geolocated) {
      params['distance'] = '${address.latitude},${address.longitude},$distance';
    }
    if (vehicles != null && vehicles.length > 0) {
      params['vehicle'] = vehicles.map((v) => v.id).join(",");
    }
    if (services != null && services.length > 0) {
      params['service'] = services.map((s) => s.id).join(",");
    }
    if (user != null) {
      params['customer.user'] = user;
    }
    if (sort != null) {
      params['order[$sort]'] = '';
    }
    return params;
  }
}

class JobService extends CrudService<Job> {
  JobService() : super(resource: 'jobs', fromJson: (data) => Job.fromJson(data), toJson: (job) => job.toJson());

  Future<JobApplication> apply(String job, String mechanic) {
    return api.post('/api/job_applications', data: {'mechanic': mechanic, 'job': job}).then((data) {
      return JobApplication.fromJson(data);
    });
  }
}

class JobApplicationQueryParameters extends PaginatedQueryParameters {
  int mechanic;
  JobApplicationQueryParameters({this.mechanic, String q, int page, int itemsPerPage}) : super(q: q, page: page, itemsPerPage: itemsPerPage);

  Map<String, dynamic> toJson() {
    var params = super.toJson();
    if (mechanic != null) {
      params['mechanic'] = mechanic;
    }
    return params;
  }
}

class JobApplicationService extends CrudService<JobApplication> {
  JobApplicationService() : super(resource: 'job_applications', fromJson: (data) => JobApplication.fromJson(data), toJson: (application) => application.toJson());
}