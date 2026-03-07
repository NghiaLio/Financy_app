// ignore_for_file: file_names

import 'dart:math';

class GenerateID {
  static final Random _random = Random();
  static int _counter = _random.nextInt(0xFFFFFF);

  /// Generate a MongoDB ObjectID-compatible string (24 hex characters)
  /// Format: 4-byte timestamp + 5-byte random + 3-byte counter
  static String newID() {
    // Get current timestamp in seconds (4 bytes)
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toRadixString(16)
        .padLeft(8, '0');

    // Generate 5 bytes (10 hex chars) of random data
    final randomBytes =
        List.generate(
          5,
          (_) => _random.nextInt(256),
        ).map((e) => e.toRadixString(16).padLeft(2, '0')).join();

    // Increment counter and get 3 bytes (6 hex chars)
    _counter = (_counter + 1) % 0xFFFFFF;
    final counter = _counter.toRadixString(16).padLeft(6, '0');

    // Combine to create 24-character hex string
    return '$timestamp$randomBytes$counter';
  }
}
