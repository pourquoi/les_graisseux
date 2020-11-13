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
      'q': q == '' ? null : q,
      'page': page,
      'itemsPerPage': itemsPerPage
    }..removeWhere((key, value) => value == null);
  }
}

class PaginatedQueryResponse<T> {
  List<T> items = List<T>();
  int total = 0;
  String first;
  String next;
  String last;
}

class CrudService<T> extends GetxService {
  ApiService api;
  String resource;

  CrudService({@required this.resource, @required this.fromJson, @required this.toJson}) {
    api = Get.find<ApiService>();
  }

  T Function(Map<String, dynamic>) fromJson;
  Map<String, dynamic> Function(T) toJson;

  PaginatedQueryResponse<T> _parseJsonList(Map<String, dynamic> data) {
    PaginatedQueryResponse<T> qr = PaginatedQueryResponse<T>();

      qr.items = data['hydra:member']
          .toList()
          .map((m) => fromJson(m))
          .toList()
          .cast<T>();
      qr.total = data['hydra:totalItems'];
      
      if (data.containsKey('hydra:view')) {
        Map<String, dynamic> hydraView = (data['hydra:view'] as Map<String, dynamic>);
        if (hydraView.containsKey('hydra:next')) qr.next = hydraView['hydra:next'];
        if (hydraView.containsKey('hydra:first')) qr.first = hydraView['hydra:next'];
        if (hydraView.containsKey('hydra:last')) qr.last = hydraView['hydra:last'];
      }

      return qr;
  }

  Future<PaginatedQueryResponse<T>> search(PaginatedQueryParameters params) {
    print('CrudService.search');

    return api.get('/api/$resource', queryParameters: params.toJson()..removeWhere((key, value) => value == null)).then((data) => _parseJsonList(data));
  }

  Future<PaginatedQueryResponse<T>> next(PaginatedQueryResponse response) => api.get(response.next).then((data) => _parseJsonList(data));
  Future<PaginatedQueryResponse<T>> last(PaginatedQueryResponse response) => api.get(response.last).then((data) => _parseJsonList(data));
  Future<PaginatedQueryResponse<T>> first(PaginatedQueryResponse response) => api.get(response.first).then((data) => _parseJsonList(data));

  Future<T> get(dynamic id) {
    return api.get('/api/$resource/$id').then((data) {
      return fromJson(data);
    });
  }

  Future<T> post(T res) {
    return api.post('/api/$resource', data:toJson(res)..removeWhere((key, value) => value == null)).then((data) {
      return fromJson(data);
    });
  }

  Future<T> put(dynamic id, T res) {
    return api.put('/api/$resource/${id}', data:toJson(res)..removeWhere((key, value) => value == null)).then((data) {
      return fromJson(data);
    });
  }

  Future<T> patch(dynamic id, Map<String, dynamic> data) {
    return api.patch('/api/$resource/$id', data: data).then((data) {
      return fromJson(data);
    });
  }
}
