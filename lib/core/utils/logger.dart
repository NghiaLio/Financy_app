import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Debug logger that automatically disables in release mode
/// Usage: debugLog('[Tag] Your message here');
void debugLog(
  String message, {
  String? name,
  Object? error,
  StackTrace? stackTrace,
}) {
  if (kDebugMode) {
    developer.log(
      message,
      name: name ?? '',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Print-style logger that also respects debug mode
void debugPrint(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print(message);
  }
}
