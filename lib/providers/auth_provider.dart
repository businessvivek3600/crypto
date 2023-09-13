// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_global_tools/providers/WalletProvider.dart';
import '../repo_injection.dart';
import '/functions/functions.dart';
import '/models/user/user_data_model.dart';
import '../route_management/route_name.dart';
import '../utils/my_toasts.dart';
import '/constants/api_const.dart';
import '/utils/api_handler_utils.dart';
import '/utils/default_logger.dart';

import '../functions/repositories/auth_repo.dart';
import '../widgets/MultiStageButton.dart';
import 'connectivity_provider.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepo authRepo;
  final String tag = 'AuthProvider';
  AuthProvider({required this.authRepo});
  UserData user = UserData();

  UserData get currentUser => user;
  ButtonLoadingState updatingProfile = ButtonLoadingState.idle;
  String? updateMessage;
  Future<(Map<String, dynamic>?, bool)?> updateUserName(
      String? username, String? refCode, BuildContext context) async {
    String? errorText;
    Map map = {};
    try {
      updatingProfile = ButtonLoadingState.loading;
      errorText = '';
      notifyListeners();
      var (data, status, ce) = await ApiHandler.hitApi(
          tag,
          ApiConst.updateUserName,
          () => authRepo
              .updateUserName({'username': username, 'referralCode': refCode}));
      infoLog(', status: $status', tag);
      if (status) {
        try {
          UserData user = UserData.fromJson(data!['user']);
          await updateUser(user);
          updatingProfile = ButtonLoadingState.completed;
          Toasts.fToast('Profile setup completed');
          await future(1000);
          // updateMessage = errorText = data[];
          notifyListeners();
          context.goNamed(RouteName.home);
          return (data, status);
        } catch (e) {
          errorLog('updateUserName $e', tag);
        }
      } else {
        updatingProfile = ButtonLoadingState.failed;
        errorText = data?['message'];
        notifyListeners();
      }
    } catch (e) {
      // await Future.delayed(const Duration(seconds: 3));
      updatingProfile = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong!';
      notifyListeners();
    }
    // await Future.delayed(const Duration(seconds: 1));
    updatingProfile = ButtonLoadingState.idle;
    updateMessage = errorText;
    if (updateMessage != null) {
      Toasts.fToast(updateMessage!);
    }
    updateMessage = null;
    notifyListeners();
    return null;
  }

  // ButtonLoadingState importingWallet = ButtonLoadingState.idle;
  // importWallet(List<String> mnemonic) async {
  //   WalletProvider provider = sl.get<WalletProvider>();
  //   importingWallet = ButtonLoadingState.loading;
  //   notifyListeners();
  //   (Map<String, dynamic>, bool)? data =
  //       await provider.verifyMnemonics(mnemonic);
  //   if (data != null && data.$2) {
  //     try {
  //       UserData user = UserData.fromJson(data.$1['user']);
  //       String token = data.$1['token'];
  //       importingWallet = ButtonLoadingState.completed;
  //       notifyListeners();
  //       Toasts.fToast('Wallet imported successfully!');
  //       await future(1000);
  //       await StreamAuth().signIn(user, token);
  //       Get.context!.goNamed(RouteName.createUsername);
  //     } catch (e) {
  //       importingWallet = ButtonLoadingState.failed;
  //       notifyListeners();
  //       errorLog(e.toString());
  //       Toasts.fToast('Some thing happened wrong!');
  //     }
  //   } else {
  //     importingWallet = ButtonLoadingState.failed;
  //     notifyListeners();
  //     Toasts.fToast(data?.$1['message'] ?? '');
  //   }
  // }

  ButtonLoadingState loginStatus = ButtonLoadingState.idle;
  String? errorText;
  Future<void> login({required bool status}) async {
    Map map = {};
    try {
      if (isOnline) {
        loginStatus = ButtonLoadingState.loading;
        errorText = '';
        notifyListeners();
        await Future.delayed(const Duration(seconds: 3));
        if (status) {
          try {
            loginStatus = ButtonLoadingState.completed;
            errorText = 'success message';
            notifyListeners();
          } catch (e) {}
        } else {
          loginStatus = ButtonLoadingState.failed;
          errorText = 'error message';
          notifyListeners();
        }
      } else {
        loginStatus = ButtonLoadingState.failed;
        errorText = 'failed message';
        notifyListeners();
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 3));
      loginStatus = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong!';
      notifyListeners();
    }
    await Future.delayed(const Duration(seconds: 3));
    loginStatus = ButtonLoadingState.idle;
    errorText = null;
    notifyListeners();
  }

  Future<void> updateUser(UserData newUser) async {
    user = newUser;
    notifyListeners();
    await authRepo.saveUser(newUser);
    logD('user update in prefs successfully! ${user.toJson()}', tag);
  }

  Future<UserData?> getUser() async {
    return await authRepo.getUser();
  }

  Future<void> refreshMyWallets() async {
    if (isOnline) {
      List<Wallet> myWallets = user.wallet ?? [];
      for (var item in myWallets) {
        Map<String, dynamic>? data = await sl
            .get<WalletProvider>()
            .getBalance(item.tokenName ?? '', item.walletAddress ?? '');
        if (data != null) {
          try {
            item.balance = (data['balance'] ?? 0).toDouble();
          } catch (e) {
            errorLog(e.toString(), 'verify');
          }
        }
      }
      user.wallet = myWallets;
      await updateUser(user);
    } else {
      Toasts.fToast('No internet connection!');
    }
  }

  Future<void> saveLoginToken(String token) async =>
      await authRepo.saveLoginToken(token);
  Future<void> clearUser() async => await authRepo.clearUser();
}
