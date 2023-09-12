// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repo_injection.dart';
import '/providers/auth_provider.dart';
import '/utils/default_logger.dart';
import '/utils/my_toasts.dart';

import '../models/base/api_response.dart';
import '../models/base/error_response.dart';
import '../providers/connectivity_provider.dart';

class ApiHandler {
  static const String _tag = 'ApiHandler';
  static void checkApi(ApiResponse apiResponse, {bool logout = false}) {
    if (apiResponse.error is! String &&
        apiResponse.error.errors[0].message == 'Unauthorized.') {
      if (logout) {
        //todo: clear auth data and others
        sl.get<AuthProvider>().clearUser();
        // Provider.of<ProfileProvider>(context,listen: false).clearHomeAddress();
        // Provider.of<ProfileProvider>(context,listen: false).clearOfficeAddress();

        ///TODO: route to login screen on
        // Navigator.of(context).pushAndRemoveUntil(
        //     MaterialPageRoute(builder: (context) => LoginScreen()),
        //         (route) => false);
      }
    } else {
      String errorMessage;
      if (apiResponse.error is String) {
        errorMessage = apiResponse.error.toString();
      } else {
        errorMessage = apiResponse.error.errors[0].message;
      }
      errorLog(errorMessage, _tag);
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          content:
              Text(errorMessage, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
    }
  }

  static void handleUncaughtError(BuildContext context, ApiResponse apiResponse,
      {bool showToast = true}) {
    String errorMessage = "";
    if (apiResponse.error is String) {
      errorMessage = apiResponse.error.toString();
    } else {
      ErrorResponse errorResponse = apiResponse.error;
      errorMessage = errorResponse.errors[0].message;
    }
    if (showToast) {
      Toasts.showErrorNormalToast(context, errorMessage);
    }
  }

  static Future<(Map<String, dynamic>?, bool, bool)> hitApi(
      String tag, String endPoint, Future<ApiResponse> Function() method,
      {bool cache = false}) async {
    bool cacheExist = await APICacheManager().isAPICacheKeyExist(endPoint);
    Map<String, dynamic>? map;
    bool status = false;
    infoLog('cache exist $endPoint $cacheExist $isOnline $cache');
    if (isOnline) {
      ApiResponse apiResponse = await method();
      if (apiResponse.response != null) {
        map = apiResponse.response!.data;
        if ((apiResponse.response!.statusCode ?? 0) >= 200 &&
            (apiResponse.response!.statusCode ?? 0) < 300) {
          try {
            status = map?["status"] ?? false;
          } catch (e) {
            errorLog(e.toString(), tag);
          }
          try {
            if (status) {
              if (map != null && cache) {
                var cacheModel =
                    APICacheDBModel(key: endPoint, syncData: jsonEncode(map));
                await APICacheManager().addCacheData(cacheModel);
                infoLog('$endPoint cache generated', tag);
              }
            }
          } catch (e) {
            errorLog('$endPoint cache could not be generated  $e', tag);
          }
        } else {
          checkApi(apiResponse);
          return (map, status, cacheExist);
        }
      }
    } else if (!isOnline && cacheExist && cache) {
      var data = (await APICacheManager().getCacheData(endPoint)).syncData;
      try {
        map = jsonDecode(data);
        status = true;
        return (map, status, cacheExist);
      } catch (e) {
        errorLog('$endPoint could not retrieve cache data', tag);
      }
    } else {
      Toasts.showWarningNormalToast(Get.context!, 'You are offline. Retry!');
    }
    return (map, status, cacheExist);
  }
}
