import 'package:app/models/service_tree.dart';
import 'package:app/services/crud.dart';

class ServiceTreeQueryParameters extends PaginatedQueryParameters {
  bool root;

  ServiceTreeQueryParameters({this.root, String q, int page, int itemsPerPage}) : super(q: q, page: page, itemsPerPage: itemsPerPage);

  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({
      'translations.label': q
    });
  }
}

class ServiceTreeService extends CrudService<ServiceTree> {
  ServiceTreeService() : super(resource: 'services', fromJson: (data) => ServiceTree.fromJson(data), toJson: (service) => service.toJson());
}
