// ignore_for_file: file_names

import 'package:hive/hive.dart';

part 'userModels.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String uid;

  @HiveField(2)
  String name;

  @HiveField(3)
  String email;

  @HiveField(4)
  String picture;

  @HiveField(5)
  DateTime dateOfBirth;

  @HiveField(6)
  DateTime createdAt;

  UserModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.picture,
    required this.dateOfBirth,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    DateTime? createdAt;
    try {
      parsedDate = json['dateOfBirth'] != null ? DateTime.parse(json['date']) : null;
      createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    } catch (e) {
      parsedDate = null;
      createdAt = null; // or set a default value
    }
    return UserModel(
      id: json['_id'] ?? '',
      uid: json['uid'] ?? '',
      name: json['userName'] ?? '',
      email: json['email'] ?? '',
      picture: json['photo'] ?? '',
      dateOfBirth: parsedDate ?? DateTime.now(),
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'uid': uid,
    'name': name,
    'email': email,
    'picture': picture,
    'dateOfBirth': dateOfBirth.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };
}
