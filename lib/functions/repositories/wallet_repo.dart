import 'dart:convert';

import 'package:dio/dio.dart';
import '/utils/default_logger.dart';
import '/constants/api_const.dart';
import '/constants/sp_constants.dart';
import '/models/user/user_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/base/api_response.dart';
import '../dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';

class WalletRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  WalletRepo({required this.dioClient, required this.sharedPreferences});

  ///:register
  Future<ApiResponse> generateMnemonic() async {
    try {
      Response response = await dioClient.get(ApiConst.generateMnemonic);
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

  Future<ApiResponse> selectWallet(bool token) async {
    try {
      Response response =
          await dioClient.get(ApiConst.selectWallet, token: token);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> confirmTransaction(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(ApiConst.confirmTransaction,
          data: data, token: true);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getBalance(Map<String, dynamic> data) async {
    try {
      Response response =
          await dioClient.post(ApiConst.getBalance, data: data, token: true);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> initTransaction(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(ApiConst.initTransaction,
          token: true, data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
