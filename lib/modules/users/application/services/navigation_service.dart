import 'package:flutter/material.dart';

/// Abstract interface for navigation operations
abstract class NavigationService {
  Future<T?> navigateTo<T extends Object?>(String routeName, {Object? arguments});
  Future<T?> navigateAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  });
  void pop<T extends Object?>([T? result]);
  bool canPop();
}

/// Implementation using Flutter's Navigator with GlobalKey
class GlobalKeyNavigationService implements NavigationService {
  final GlobalKey<NavigatorState> navigatorKey;

  GlobalKeyNavigationService({required this.navigatorKey});

  @override
  Future<T?> navigateTo<T extends Object?>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }

  @override
  Future<T?> navigateAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  @override
  void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState!.pop<T>(result);
  }

  @override
  bool canPop() {
    return navigatorKey.currentState!.canPop();
  }
}

/// Implementation using BuildContext (for simpler cases)
class ContextNavigationService implements NavigationService {
  final BuildContext context;

  ContextNavigationService({required this.context});

  @override
  Future<T?> navigateTo<T extends Object?>(String routeName, {Object? arguments}) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  @override
  Future<T?> navigateAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  @override
  void pop<T extends Object?>([T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  @override
  bool canPop() {
    return Navigator.of(context).canPop();
  }
}
