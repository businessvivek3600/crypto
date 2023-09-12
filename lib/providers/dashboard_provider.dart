import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import '/functions/functions.dart';
import '/models/coin_model.dart';
import '/models/user/user_data_model.dart';
import '/utils/my_toasts.dart';

import '../constants/api_const.dart';
import '../functions/repositories/dash_repo.dart';
import '../models/recent_users.dart';
import '../models/wallet_model.dart';
import '../utils/api_handler_utils.dart';
import '../utils/default_logger.dart';
import '../widgets/MultiStageButton.dart';

enum CoinGraphType { day, week, month, year }

class DashboardProvider extends ChangeNotifier {
  final DashRepo dashRepo;
  DashboardProvider({required this.dashRepo});

  final String tag = 'DashboardProvider';
  int bottomIndex = 0;
  setBottomIndex(int val) {
    bottomIndex = val;
    notifyListeners();
  }

  final ScrollController scrollController = ScrollController();
  bool showTextField = true;
  void onScroll() {
    if (scrollController.position.userScrollDirection ==
            ScrollDirection.reverse &&
        showTextField) {
      showTextField = false;
      notifyListeners();
    } else if (scrollController.position.userScrollDirection ==
            ScrollDirection.forward &&
        !showTextField) {
      showTextField = true;
      notifyListeners();
    }
  }

  CoinModel? coinModel;
  CoinGraphType graphType = CoinGraphType.day;
  setGraphType(CoinGraphType val) {
    graphType = val;
    notifyListeners();
  }

  ButtonLoadingState loadingCoins = ButtonLoadingState.idle;
  Future<void> getCoins(BuildContext context, bool loading) async {
    String? errorText;
    Map map = {};
    try {
      loadingCoins =
          loading ? ButtonLoadingState.loading : ButtonLoadingState.idle;
      notifyListeners();
      var (data, status, ce) = await ApiHandler.hitApi(
          tag, ApiConst.getCoins, () => dashRepo.getCoins(),
          cache: true);
      if (status) {
        try {
          coinModel = CoinModel.fromJson(data!);
          await future(1000);
          loadingCoins = ButtonLoadingState.completed;
          notifyListeners();
        } catch (e) {
          loadingCoins = ButtonLoadingState.failed;
          errorText = 'Some thing went wrong!';
          notifyListeners();
          errorLog('getCoins $e', tag);
        }
      } else {
        loadingCoins = ButtonLoadingState.failed;
        errorText = data?['message'];
        notifyListeners();
      }
    } catch (e) {
      loadingCoins = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong!';
      notifyListeners();
    }
    loadingCoins = ButtonLoadingState.idle;
    if (errorText != null) {
      Toasts.fToast(errorText);
    }

    notifyListeners();
  }

  ButtonLoadingState loadingRecentUsers = ButtonLoadingState.idle;
  List<RecentUsers> recentUsers = [];
  Future<void> getRecentUsers(BuildContext context,
      [bool loading = true, bool token = true]) async {
    String? errorText;
    try {
      loadingRecentUsers =
          loading ? ButtonLoadingState.loading : ButtonLoadingState.idle;
      notifyListeners();
      var (data, status, ce) = await ApiHandler.hitApi(
          tag, ApiConst.recentUsers, () => dashRepo.recentUsers(token),
          cache: true);
      infoLog('data: $data');
      if (status) {
        try {
          if (data!['recentUsers'] != null) {
            recentUsers.clear();
            data['recentUsers'].forEach((e) {
              recentUsers.add(RecentUsers.fromJson(e));
            });
          }
          loadingRecentUsers = ButtonLoadingState.completed;
          notifyListeners();
        } catch (e) {
          loadingRecentUsers = ButtonLoadingState.failed;
          errorText = 'Some thing went wrong!';
          notifyListeners();
          errorLog('recentUsers $e', tag);
        }
      } else {
        loadingRecentUsers = ButtonLoadingState.failed;
        errorText = data?['message'];
        notifyListeners();
      }
    } catch (e) {
      loadingRecentUsers = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong!';
      notifyListeners();
    }
    loadingRecentUsers = ButtonLoadingState.idle;
    if (errorText != null) {
      Toasts.fToast(errorText);
    }
    notifyListeners();
  }

  ButtonLoadingState loadingSearchUsers = ButtonLoadingState.idle;
  List<RecentUsers> searchedUsers = [];
  Future<void> searchUsers(BuildContext context, String query,
      [bool loading = true]) async {
    String? errorText;
    try {
      loadingSearchUsers =
          loading ? ButtonLoadingState.loading : ButtonLoadingState.idle;
      notifyListeners();
      var (data, status, ce) = await ApiHandler.hitApi(tag, ApiConst.searchUser,
          () => dashRepo.searchUsers({'query': query}));
      infoLog('searchUsers $data');
      if (status) {
        try {
          searchedUsers.clear();
          if (data!['users'] != null &&
              data['users'] is List &&
              data['users'].isNotEmpty) {
            data['users'].forEach((e) {
              searchedUsers.add(RecentUsers.fromJson(e));
            });
          }
          loadingSearchUsers = ButtonLoadingState.completed;
          notifyListeners();
        } catch (e) {
          loadingSearchUsers = ButtonLoadingState.failed;
          errorText = 'Some thing went wrong!';
          notifyListeners();
          errorLog('recentUsers $e', tag);
        }
      } else {
        loadingSearchUsers = ButtonLoadingState.failed;
        errorText = data?['message'];
        notifyListeners();
      }
    } catch (e) {
      loadingSearchUsers = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong!';
      notifyListeners();
    }
    loadingSearchUsers = ButtonLoadingState.idle;
    if (errorText != null) {
      Toasts.fToast(errorText);
    }
    notifyListeners();
  }

  ButtonLoadingState loadingInitTrans = ButtonLoadingState.idle;
  Future<Map<String, dynamic>?> initTransaction(
      BuildContext context, Map<String, String?> walletData,
      [bool loading = true]) async {
    String? errorText;
    try {
      loadingInitTrans =
          loading ? ButtonLoadingState.loading : ButtonLoadingState.idle;
      notifyListeners();
      var (data, status, ce) = await ApiHandler.hitApi(tag,
          ApiConst.initTransaction, () => dashRepo.initTransaction(walletData),
          cache: false);
      // infoLog('data: $data');
      if (status) {
        try {
          loadingInitTrans = ButtonLoadingState.completed;
          notifyListeners();
          return data;
        } catch (e) {
          loadingInitTrans = ButtonLoadingState.failed;
          errorText = 'Some thing went wrong!';
          notifyListeners();
          errorLog('initTransaction $e', tag);
        }
      } else {
        loadingInitTrans = ButtonLoadingState.failed;
        errorText = data?['message'];
        notifyListeners();
      }
    } catch (e) {
      loadingInitTrans = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong!';
      notifyListeners();
    }
    loadingInitTrans = ButtonLoadingState.idle;
    notifyListeners();
    if (errorText != null) {
      Toasts.fToast(errorText);
    }
    return null;
  }
}
