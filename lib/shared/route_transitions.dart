import 'package:flutter/material.dart';

/// Custom page route transitions for smooth, elegant navigation
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final SlideDirection direction;

  SlidePageRoute({
    required this.child,
    this.direction = SlideDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offset = _getOffset(direction);
            final tween = Tween<Offset>(
              begin: offset,
              end: Offset.zero,
            );
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );

  static Offset _getOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.right:
        return const Offset(1.0, 0.0);
      case SlideDirection.left:
        return const Offset(-1.0, 0.0);
      case SlideDirection.top:
        return const Offset(0.0, -1.0);
      case SlideDirection.bottom:
        return const Offset(0.0, 1.0);
    }
  }
}

enum SlideDirection {
  right,
  left,
  top,
  bottom,
}

/// Fade page route for modal-like transitions
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FadePageRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

/// Scale page route for zoom-like transitions
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  ScalePageRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

/// Helper extension for easy navigation with transitions
extension NavigationExtensions on BuildContext {
  void pushSlide<T>(Widget page, {SlideDirection direction = SlideDirection.right}) {
    Navigator.push<T>(
      this,
      SlidePageRoute(child: page, direction: direction),
    );
  }

  void pushFade<T>(Widget page) {
    Navigator.push<T>(
      this,
      FadePageRoute(child: page),
    );
  }

  void pushScale<T>(Widget page) {
    Navigator.push<T>(
      this,
      ScalePageRoute(child: page),
    );
  }

  void pushReplacementSlide<T>(Widget page, {SlideDirection direction = SlideDirection.right}) {
    Navigator.pushReplacement<T, T>(
      this,
      SlidePageRoute(child: page, direction: direction),
    );
  }

  void pushAndRemoveUntilSlide(Widget page, {SlideDirection direction = SlideDirection.right}) {
    Navigator.pushAndRemoveUntil(
      this,
      SlidePageRoute(child: page, direction: direction),
      (route) => false,
    );
  }
}

