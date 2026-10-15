import 'package:flutter/material.dart';

/// Shared transition for the authentication flow.
Route<T> animatedPage<T>(BuildContext context, Widget page) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return PageRouteBuilder<T>(
    transitionDuration: Duration(milliseconds: reduceMotion ? 0 : 420),
    reverseTransitionDuration: Duration(milliseconds: reduceMotion ? 0 : 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(.08, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
