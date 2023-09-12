// ignore_for_file: constant_pattern_never_matches_value_type

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/utils/default_logger.dart';

CustomTransitionPage animatedRoute(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    barrierDismissible: true,
    barrierColor: Colors.black38,
    opaque: false,
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage animatedRoute2(
    GoRouterState state, Widget Function(GoRouterState state) child,
    {RouteTransition? transition}) {
  infoLog(
      '#state.queryParameters[\'animation\']  ${state.queryParameters}  is ${state.queryParameters['anim']}',
      'My Router',
      'animatedRoute2');
  RouteTransition pageTransition = transition ??
      RouteTransition.values.firstWhere((element) =>
          element.name ==
          (state.queryParameters['anim'] ?? RouteTransition.fromLeft.name));
  return CustomTransitionPage(
      key: state.pageKey,
      child: child(state),
      barrierDismissible: true,
      barrierColor: Colors.black38,
      // opaque: false,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (pageTransition) {
          case RouteTransition.slide:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.fromTop:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.fromBottom:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.fomRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.topLeft:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, -1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.topRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, -1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.bottomLeft:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.bottomRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          case RouteTransition.scale:
            return FadeTransition(
              opacity: Tween<double>(begin: 0.6, end: 1.0).animate(animation),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
                child: child,
              ),
            );
          default:
            return FadeTransition(
              opacity: Tween<double>(begin: .5, end: 1.0).animate(animation),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
        }
      });
}

enum RouteTransition {
  slide,
  fromTop,
  fromBottom,
  fomRight,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  fade,
  scale,
  fromLeft,
}
