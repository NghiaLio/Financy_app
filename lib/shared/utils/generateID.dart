// ignore_for_file: file_names

import 'package:uuid/uuid.dart';

class GenerateID {
  static String newID() {
    return Uuid().v4();
  }
}
