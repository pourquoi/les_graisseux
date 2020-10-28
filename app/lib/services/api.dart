import 'dart:convert';
import 'dart:ui' as ui;
import 'package:app/config.dart';
import 'package:app/utils/api_transformer.dart';
import 'package:dio/dio.dart';
import 'package:get/state_manager.dart';

class ApiService extends GetxService {
  Dio _dio;
  Interceptor _authInterceptor;

  ApiService() {
    BaseOptions options = new BaseOptions(baseUrl: API_HOST, headers: {
      "Content-Type": "application/ld+json",
      "Accept-Language": ui.window.locale.toString()
    });
    _dio = Dio(options);
    _dio.transformer = ApiTransformer();
  }

  Future<T> get<T>(path, {Map<String, dynamic> queryParameters}) {
    print(path);
    return _dio
      .get<dynamic>(path, queryParameters: queryParameters)
      .then((response) {
        print(response.data);
        return response.data;
      }).catchError((error) {
        throw error;
      });
  }

  Future<T> post<T>(path,
          {dynamic data, Map<String, dynamic> queryParameters}) =>
      _post('POST', path, data: data, queryParameters: queryParameters);

  Future<T> put<T>(path,
          {dynamic data, Map<String, dynamic> queryParameters}) =>
      _post('PUT', path, data: data, queryParameters: queryParameters);

  Future<T> patch<T>(path,
          {dynamic data, Map<String, dynamic> queryParameters}) =>
      _post('PATCH', path, data: data, queryParameters: queryParameters);

  Future<T> _post<T>(String method, path,
      {dynamic data, Map<String, dynamic> queryParameters}) {
        print('$method $path');
        print(data);
    String payload = json.encode(data);
    return _dio
        .request<dynamic>(path,
            data: payload,
            queryParameters: queryParameters,
            options: Options(method: method))
        .then((response) {
      return response.data;
    }).catchError((error) {
      throw error;
    });
  }

  set token(RxString token) {
    if (_authInterceptor != null &&
        _dio.interceptors.contains(_authInterceptor)) {
      _dio.interceptors.remove(_authInterceptor);
    }
    if (token == null) return;
    _authInterceptor = InterceptorsWrapper(
        onRequest: (RequestOptions options) async {
          if (token.value != null)
            options.headers['Authorization'] = "Bearer ${token.value}";
          else if (options.headers.containsKey('Authorization'))
            options.headers.remove('Authorization');

          print(options.headers);
        },
        onResponse: (Response response) async {},
        onError: (DioError e) async {
          if (e.response != null) {
            if (e.response.statusCode == 401) {}
          }
          return e;
        });
    _dio.interceptors.add(_authInterceptor);
  }

  Dio get dio => _dio;
}
