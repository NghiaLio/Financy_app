// ignore_for_file: file_names

import 'package:hive/hive.dart';

part 'guestModels.g.dart';

@HiveType(typeId: 0)
class GuestModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String picture;

  @HiveField(2)
  DateTime createdAt;

  GuestModel({
    required this.name,
    required this.picture,
    required this.createdAt,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    try {
      parsedDate = json['date'] != null ? DateTime.parse(json['date']) : null;
    } catch (e) {
      parsedDate = null; // or set a default value
    }
    return GuestModel(
      name: json['userName'] ?? '',
      picture: json['photo'] ?? '',
      createdAt: parsedDate ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'picture': picture,
    'createdAt': createdAt.toIso8601String(),
  };
}
