import 'package:app/models/mechanic.dart';
import 'package:app/services/crud_service.dart';

class MechanicQueryParameters extends PaginatedQueryParameters {
  double minRating;

  MechanicQueryParameters({this.minRating, String q, int page, int itemsPerPage}) : super(q: q, page: page, itemsPerPage: itemsPerPage);

  Map<String, dynamic> toJson() {
    var params = super.toJson();
    if (minRating != null) {
      params['rating'] = minRating;
    }
    return params;
  }
}

class MechanicService extends CrudService<Mechanic> {
  MechanicService() : super(resource: 'mechanics');

  Mechanic fromJson(m) => Mechanic.fromJson(m);
}
