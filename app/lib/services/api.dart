import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:app/config.dart';
import 'package:app/utils/api_transformer.dart';
import 'package:dio/dio.dart';
import 'package:get/state_manager.dart';

/// Wrapper of the api http client.
class ApiService extends GetxService {
  Dio _dio;
  Interceptor _authInterceptor;
  
  StreamController<DioError> _errorStream = StreamController<DioError>();

  Stream<DioError> get errorStream => _errorStream.stream;
  Dio get dio => _dio;

  ApiService() {
    BaseOptions options = new BaseOptions(baseUrl: API_HOST, headers: {
      "Content-Type": "application/ld+json",
      "Accept-Language": ui.window.locale.toString()
    });

    _dio = Dio(options);
    _dio.transformer = ApiTransformer();
    
    // base interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options) {
        print("REQUEST[${options?.method}] => PATH: ${options?.path}");
        options.headers.remove('content-type');
      },
      onResponse: (Response response) {
        print("RESPONSE[${response?.statusCode}] => PATH: ${response?.request?.path}");
      },
      onError: (DioError err) {
        print("ERROR[${err?.response?.statusCode}] => PATH: ${err?.request?.path}");
        _errorStream.add(err);
      }
    ));
  }

  void onClose() {
    _errorStream.close();
  }

  Future<T> get<T>(path, {Map<String, dynamic> queryParameters}) {
    return _dio
      .get<dynamic>(path, queryParameters: queryParameters)
      .then((response) {
        return response.data;
      });
  }

  Future<T> post<T>(path, {dynamic data, Map<String, dynamic> queryParameters}) =>
      _post('POST', path, data: data, queryParameters: queryParameters);

  Future<T> put<T>(path, {dynamic data, Map<String, dynamic> queryParameters}) =>
      _post('PUT', path, data: data, queryParameters: queryParameters);

  Future<T> patch<T>(path, {dynamic data, Map<String, dynamic> queryParameters}) =>
      _post('PATCH', path, data: data, queryParameters: queryParameters, headers: {"Content-Type": "application/merge-patch+json",});

  Future<T> _post<T>(String method, path, {dynamic data, Map<String, dynamic> queryParameters, Map<String, dynamic> headers}) {
    if (data is FormData) {
      return _dio.request(path, data: data, options: Options(method: method, headers: {"Content-Type": "multipart/form-data"})).then((response) {
        return response.data;
      }).catchError((error) {
        throw error;
      });
    }

    String payload = json.encode(data);
    return _dio
        .request<dynamic>(path,
            data: payload,
            queryParameters: queryParameters,
            options: Options(method: method, headers: headers))
        .then((response) {
      return response.data;
    });
  }

  /// Update the Bearer token.
  set token(token) {
    if (_authInterceptor != null && _dio.interceptors.contains(_authInterceptor)) {
      _dio.interceptors.remove(_authInterceptor);
    }

    _authInterceptor = InterceptorsWrapper(
      onRequest: (RequestOptions options) async {
        if (token != null) {
          options.headers['Authorization'] = "Bearer ${token}";
        } else {
          options.headers.remove('Authorization');
        }
      }
    );

    _dio.interceptors.add(_authInterceptor);
  }
}
