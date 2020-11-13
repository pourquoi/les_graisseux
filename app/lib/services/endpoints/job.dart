import 'package:app/models/address.dart';
import 'package:app/models/job.dart';
import 'package:app/models/job_application.dart';
import 'package:app/services/crud_service.dart';

class JobQueryParameters extends PaginatedQueryParameters {
  int distance;
  dynamic user;
  Address address;

  JobQueryParameters({this.address, this.distance, String q, int page, int itemsPerPage}) : super(q: q, page: page, itemsPerPage: itemsPerPage);

  Map<String, dynamic> toJson() {
    var params = super.toJson();
    if (address != null && distance != null && address.geolocated) {
      params['distance'] = '${address.latitude},${address.longitude},$distance';
    }
    if (user != null) {
      params['customer.user'] = user;
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