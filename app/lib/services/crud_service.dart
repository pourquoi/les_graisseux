import 'package:meta/meta.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';

import 'package:app/services/api.dart';

class PaginatedQueryParameters {
  int itemsPerPage = 30;
  int page = 1;
  String q;

  PaginatedQueryParameters({this.q, this.page = 1, this.itemsPerPage = 30});

  Map<String, dynamic> toJson() {
    return {
      'q': q,
      'page': page,
      'itemsPerPage': itemsPerPage
    }..removeWhere((key, value) => value == null);
  }
}

class PaginatedQueryResponse<T> {
  List<T> items;
  int total;
}

abstract class CrudService<T> extends GetxService {
  ApiService api;
  String resource;

  CrudService({@required this.resource});

  void onInit() {
    api = Get.find<ApiService>();
  }

  T fromJson(data);

  Future<PaginatedQueryResponse<T>> search(PaginatedQueryParameters params) {

    if (params == null) params = PaginatedQueryParameters();

    return api.get('/api/$resource', queryParameters: params.toJson()).then((data) {

      print(data['hydra:member']);

      PaginatedQueryResponse<T> qr = PaginatedQueryResponse<T>();

      qr.items = data['hydra:member']
          .toList()
          .map((m) => fromJson(m))
          .toList()
          .cast<T>();
      qr.total = data['hydra:totalItems'];

      return qr;
    });
  }

  Future<T> get(dynamic id) {
    return api.get('/api/$resource/$id').then((data) {
      return fromJson(data);
    });
  }
}
