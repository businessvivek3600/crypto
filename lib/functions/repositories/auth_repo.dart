import 'dart:convert';

import 'package:dio/dio.dart';
import '/constants/api_const.dart';
import '/constants/sp_constants.dart';
import '/models/user/user_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/base/api_response.dart';
import '../dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';

class AuthRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  AuthRepo({required this.dioClient, required this.sharedPreferences});

  ///:register
  Future<ApiResponse> updateUserName(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(ApiConst.updateUserName,
          data: data, token: true);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///shared preferences

  Future<void> saveUser(UserData user) async => await sharedPreferences
      .setString(SPConst.user, jsonEncode(user.toJson()));

  Future<UserData?> getUser() async {
    UserData? user;
    var data = sharedPreferences.getString(SPConst.user);
    try {
      if (data != null) {
        user = UserData.fromJson(jsonDecode(data));
      }
    } catch (e) {}
    return user;
  }

  Future<void> saveLoginToken(String token) async {
    dioClient.updateToken(token);
    await sharedPreferences.setString(SPConst.loginToken, token);
  }

  Future<String?> getLoginToken() async =>
      sharedPreferences.getString(SPConst.loginToken);

  Future<void> clearUser() async {
    dioClient.updateToken(null);
    sharedPreferences.remove(SPConst.user);
    sharedPreferences.remove(SPConst.loginToken);
  }
}
