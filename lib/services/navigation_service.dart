import 'package:flutter/material.dart';

/// Navigation service for centralized navigation management
class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  /// Navigate to a named route
  static Future<T?>? navigateTo<T>(String routeName, {Object? arguments}) {
    return navigator?.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replace current route with a named route
  static Future<T?>? replaceTo<T>(String routeName, {Object? arguments}) {
    return navigator?.pushReplacementNamed<T, void>(routeName, arguments: arguments);
  }

  /// Pop the current route
  static void goBack<T>([T? result]) {
    navigator?.pop<T>(result);
  }

  /// Pop until a specific route
  static void popUntil(String routeName) {
    navigator?.popUntil(ModalRoute.withName(routeName));
  }

  /// Clear stack and navigate to a route
  static Future<T?>? clearStackAndNavigateTo<T>(String routeName, {Object? arguments}) {
    return navigator?.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Check if we can pop
  static bool canPop() {
    return navigator?.canPop() ?? false;
  }
}
