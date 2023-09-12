import 'dart:async';

import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '/screens/Onboardings/on_boarding_page.dart';
import '/utils/default_logger.dart';
import '/utils/sp_utils.dart';

import '../functions/repositories/auth_repo.dart';
import '../models/user/user_data_model.dart';
import '../providers/dashboard_provider.dart';
import '../repo_injection.dart';

/// A scope that provides [StreamAuth] for the subtree.
class StreamAuthScope extends InheritedNotifier<StreamAuthNotifier> {
  /// Creates a [StreamAuthScope] sign in scope.
  StreamAuthScope({super.key, required super.child})
      : super(notifier: StreamAuthNotifier());

  /// Gets the [StreamAuth].
  static StreamAuth of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StreamAuthScope>()!
        .notifier!
        .streamAuth;
  }
}

/// A class that converts [StreamAuth] into a [ChangeNotifier].
class StreamAuthNotifier extends ChangeNotifier {
  /// Creates a [StreamAuthNotifier].
  StreamAuthNotifier() : streamAuth = StreamAuth() {
    streamAuth.onCurrentUserChanged.listen((UserData? user) {
      notifyListeners();
    });
  }

  /// The stream auth client.
  final StreamAuth streamAuth;
}

/// An asynchronous log in services mock with stream similar to google_sign_in.
///
/// This class adds an artificial delay of 3 second when logging in an user, and
/// will automatically clear the login session after [refreshInterval].
class StreamAuth {
  /// Creates an [StreamAuth] that clear the current user session in
  /// [refeshInterval] second.
  StreamAuth({this.refreshInterval = 20})
      : _userStreamController = StreamController<UserData?>.broadcast() {
    _userStreamController.stream.listen((UserData? currentUser) {
      infoLog('showOnBoarding $showOnBoarding', 'StreamAuth');
      _currentUser = currentUser;
    });
  }

  /// The current user.
  UserData? get currentUser => _currentUser;
  UserData? _currentUser;

  /// Checks whether current user is signed in with an artificial delay to mimic
  /// async operation.
  Future<(bool, UserData?)> isSignedIn() async {
    // await Future<void>.delayed(const Duration(seconds: 1));
    var authProvider = sl.get<AuthProvider>();
    _currentUser = await authProvider.getUser();
    String? token = await authProvider.authRepo.getLoginToken();
    if (currentUser != null && token != null) {
      await authProvider.updateUser(currentUser!);
      await authProvider.saveLoginToken(token);
    }
    return (_currentUser != null, _currentUser);
  }

  /// A stream that notifies when current user has changed.
  Stream<UserData?> get onCurrentUserChanged => _userStreamController.stream;
  final StreamController<UserData?> _userStreamController;

  /// The interval that automatically signs out the user.
  final int refreshInterval;

  Timer? _timer;
  Timer _createRefreshTimer() {
    return Timer(Duration(seconds: refreshInterval), () {
      _userStreamController.add(null);
      _timer = null;
    });
  }

  /// Signs in a user with an artificial delay to mimic async operation.
  Future<void> signIn(UserData userData, String token,
      {bool onBoarding = false, int bottomIndex = 0}) async {
    showOnBoarding = onBoarding;
    SpUtils().setOnBoarding(false);
    var authProvider = sl.get<AuthProvider>();
    await authProvider.updateUser(userData);
    await authProvider.saveLoginToken(token);
    var currentUser = await authProvider.getUser();
    // warningLog('current user is $currentUser', 'Stream Auth');
    if (currentUser != null) {
      //   MyDialogs.showCircleLoader();
      // }
      // await Future<void>.delayed(const Duration(seconds: 3));
      // Get.back();
      _userStreamController.add(currentUser);
      sl.get<DashboardProvider>().setBottomIndex(bottomIndex);
    }
    _timer?.cancel();
    // _timer = _createRefreshTimer();
  }

  /// Signs out the current user.
  Future<void> signOut({bool onBoarding = false}) async {
    showOnBoarding = onBoarding;
    SpUtils().setOnBoarding(true);
    _timer?.cancel();
    _timer = null;
    var authRepo = sl.get<AuthRepo>();
    await authRepo.clearUser();
    var authProvider = sl.get<AuthProvider>();
    await authProvider.updateUser(UserData());
    await APICacheManager().emptyCache();
    (await SharedPreferences.getInstance()).clear();

    _userStreamController.add(await authRepo.getUser());
  }
}
