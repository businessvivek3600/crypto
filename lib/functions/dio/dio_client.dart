import 'dart:io';

import 'package:dio/dio.dart';
import '/utils/default_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logging_interceptor.dart';

class DioClient {
  final String baseUrl;
  final LoggingInterceptor loggingInterceptor;
  final SharedPreferences sharedPreferences;

  late Dio dio;
  String? bearerToken;
  String? _loginToken;
  static const String tag = 'DioClient';

  DioClient(
    this.baseUrl,
    Dio? dioC, {
    required this.loggingInterceptor,
    required this.sharedPreferences,
  }) {
    //TODO: setup tokens and other variables from global
    // token = AppConst.authorizationToken;
    dio = dioC ?? Dio();
    dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = const Duration(seconds: 5)
      ..options.receiveTimeout = const Duration(seconds: 5)
      ..httpClientAdapter
      ..options.headers = {
        //TODO: setup initial content types
        // 'content-type': 'multipart/form-data',
        'content-type': 'application/json',
        // 'authorization': 'Bearer $token',
      }
      ..options.responseType = ResponseType.json;
    dio.interceptors.add(loggingInterceptor);
  }

  void updateHeader(String? token, {String? contentType}) {
    token = token ?? bearerToken;
    bearerToken = token;
    dio.options.headers = {
      'Content-Type': contentType ?? 'application/json; charset=UTF-8',
      'authorization': 'Bearer $token',
    };
    warningLog(
        dio.options.headers.toString(), 'Dio Client', 'Updated Dio Header');
  }

  void updateLoginToken(String? userToken) {
    _loginToken = userToken ?? _loginToken;
  }

  void updateToken(String? newToken) {
    bearerToken = newToken ?? bearerToken;
  }

  Future<Response> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool token = false,
  }) async {
    try {
      warningLog('get  $uri  -> token: $token', tag);
      if (token) {
        dio.options.headers.addAll({'authorization': 'Bearer $bearerToken'});
      }
      var response = await dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    String uri, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool token = false,
  }) async {
    try {
      //TODO: uncomment if want to use formData
/*    try {
      FormData formData = FormData();
      logD(data)('post dio  data: $data');
      formData.fields.addAll((data ?? <String, dynamic>{})
          .entries
          .toList()
          .map((e) => MapEntry(e.key, e.value)));
      if (token) {
        formData.fields.add(MapEntry('login_token', _userToken ?? ''));
      }*/
      if (token) {
        dio.options.headers.addAll({'authorization': 'Bearer $bearerToken'});
      }
      logD('data->${data}');
      var response = await dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      // logD('response ->${response.data}');
      return response;
    } on FormatException catch (e) {
      throw FormatException("Unable to process the data $e");
    } catch (e) {
      errorLog(e.toString(), 'post cache error', uri);
      throw e.toString();
    }
  }

  Future<Response> put(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      var response = await dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      var response = await dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }
}
