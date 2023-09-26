import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '/utils/color.dart';
import '../../services/auth_service.dart';
import '../Onboardings/on_boarding_page.dart';
import '/route_management/route_path.dart';
import '/utils/picture_utils.dart';
import 'package:uni_links/uni_links.dart';

import '../../constants/app_const.dart';
import '../../constants/asset_constants.dart';
import '../../utils/default_logger.dart';
import '../../utils/loader.dart';
import '../../utils/my_advanved_toasts.dart';
import '../../utils/sized_utils.dart';
import '../../utils/text.dart';

bool _initialUriIsHandled = false;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool searchMode = false;

  late AnimationController _animationController;
  late Animation<double> _splashOffsetAnimation;

  @override
  void initState() {
    primaryFocus?.unfocus();
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));

    _splashOffsetAnimation = Tween<double>(begin: 300, end: 0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.fastOutSlowIn));

    _animationController.forward();
    _animationController.addListener(() => setState(() {}));

    Future.delayed(const Duration(seconds: 3), () async {
      final (loggedIn, user) = await StreamAuthScope.of(context).isSignedIn();

      if (loggedIn) {
        showOnBoarding = false;
        String? userName = user!.username;
        //go to desired page
        if (mounted && userName == null) {
          context.go(RoutePath.createUsername);
        }
        //go to home
        else {
          context.go(RoutePath.home);
        }
      }
      //go to on-boarding
      else {
        if (mounted) {
          context.go(RoutePath.onBoarding);
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: buildAppbarGradient()),
        width: double.maxFinite,
        child: Transform.translate(
          offset: Offset(0, _splashOffsetAnimation.value),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                assetImages(PNGAssets.appLogo, width: getWidth / 2),
                height20(),
                titleLargeText(AppConst.appName, context),
                const Spacer(),
                loaderWidget(radius: 10),
                height50(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  late StreamSubscription<Map<dynamic, dynamic>> deppLinkSubscription;
  void listenDeepLinks() {
    // deppLinkSubscription = FlutterBranchSdk.initSession().listen((event) {
    //   logD(event.toString(),RoutePath.splash);
    // });
  }
  Uri? _initialUri;
  Uri? _latestUri;
  String? _path;
  Object? _err;
  String tag = 'MyApp';

  StreamSubscription? _sub;

  void handleIncomingLinks() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        infoLog('got uri: $uri', tag);
        setState(() {
          _latestUri = uri;
          _err = null;
          if (uri != null) {
            _path = uri.path;
            if (_path != null) {
              warningLog('Found a path $_path', tag);
              try {
                context.push(_path!);
              } catch (e) {
                errorLog('Error while passing dep link $_path   $e', tag);
              }
            }
          }
        });
      }, onError: (Object err) {
        if (!mounted) return;
        infoLog('got err: $err', tag);
        setState(() {
          _latestUri = null;
          if (err is FormatException) {
            _err = err;
          } else {
            _err = null;
          }
        });
      });
    }
  }

  /// We handle all exceptions, since it is called from initState.
  Future<void> _handleInitialUri() async {
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a widget that will be disposed of (ex. a navigation route change).
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      AdvanceToasts.showNormalElegant(context, '_handleInitialUri called');
      try {
        final uri = await getInitialUri();
        if (uri == null) {
          infoLog('no initial uri', tag);
        } else {
          infoLog('got initial uri: $uri', tag);
        }
        if (!mounted) return;
        setState(() => _initialUri = uri);
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        infoLog('failed to get initial uri', tag);
      } on FormatException catch (err) {
        if (!mounted) return;
        infoLog('malformed initial uri', tag);
        setState(() => _err = err);
      }
    }
  }
}
