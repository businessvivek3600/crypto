import 'package:dio/dio.dart';
import '/utils/my_toasts.dart';
import '/utils/default_logger.dart';

class LoggingInterceptor extends InterceptorsWrapper {
  int maxCharactersPerLine = 200;

  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    infoLog("--> ${options.uri} ${options.method} ${options.path}");
    infoLog("Headers: ${options.headers.toString()}");
    infoLog("<-- END HTTP");
    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    successLog(
        "<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}");

    String responseAsString = response.data.toString();

    if (responseAsString.length > maxCharactersPerLine) {
      int iterations = (responseAsString.length / maxCharactersPerLine).floor();
      for (int i = 0; i <= iterations; i++) {
        int endingIndex = i * maxCharactersPerLine + maxCharactersPerLine;
        if (endingIndex > responseAsString.length) {
          endingIndex = responseAsString.length;
        }
        successLog(
            responseAsString.substring(i * maxCharactersPerLine, endingIndex));
      }
    } else {
      successLog(responseAsString);
    }
    successLog("<-- END HTTP");
    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    errorLog(
        "ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}  response: ${err.response}  extra :${err} response-type: ${err.response?.runtimeType}}");
    if (err.response != null) {
      Toasts.fToast(err.response?.data['msg'] ??
          err.response?.data['message'] ??
          'Something went wrong');
    }
    return super.onError(err, handler);
  }
}
