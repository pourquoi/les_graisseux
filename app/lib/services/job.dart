import 'package:app/models/common.dart';
import 'package:app/models/job.dart';
import 'package:app/services/crud_service.dart';

class JobQueryParameters extends PaginatedQueryParameters {
  Geocoordinate geocoordinate;
  int distance;

  JobQueryParameters({this.geocoordinate, this.distance, String q, int page, int itemsPerPage}) : super(q: q, page: page, itemsPerPage: itemsPerPage);

  Map<String, dynamic> toJson() {
    var params = super.toJson();
    if (geocoordinate != null && distance != null) {
      params['distance'] = '${geocoordinate.latitude},${geocoordinate.longitude},$distance';
    }
    return params;
  }
}

class JobService extends CrudService<Job> {
  JobService() : super(resource: 'jobs');

  Job fromJson(m) => Job.fromJson(m);
}
