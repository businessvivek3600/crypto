import 'package:dio/dio.dart';
import '/constants/api_const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/base/api_response.dart';
import '../dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';

class DashRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  DashRepo({required this.dioClient, required this.sharedPreferences});

  ///:register
  Future<ApiResponse> getCoins() async {
    try {
      Response response = await dioClient.get(ApiConst.getCoins, token: true);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> verifyMnemonic(Map<String, dynamic> data) async {
    try {
      Response response =
          await dioClient.post(ApiConst.verifyMnemonic, data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> recentUsers(bool token) async {
    try {
      Response response =
          await dioClient.get(ApiConst.recentUsers, token: token);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> searchUsers(Map<String, dynamic> data) async {
    try {
      Response response =
          await dioClient.post(ApiConst.searchUser, token: true, data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> initTransaction(Map<String, String?> data) async {
    try {
      Response response = await dioClient.post(ApiConst.initTransaction,
          token: true, data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
