import 'package:flutter/material.dart';

class FadeSlideRoute extends PageRouteBuilder {
  final Widget page;

  FadeSlideRoute({required this.page})
      : super(
    pageBuilder: (
        context,
        animation,
        secondaryAnimation,
        ) =>
    page,

    transitionsBuilder:
        (context, animation, secondaryAnimation, child) {

      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;

      var slideAnimation = Tween(
        begin: begin,
        end: end,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
      );

      var fadeAnimation = Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(animation);

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: child,
        ),
      );
    },
  );
}