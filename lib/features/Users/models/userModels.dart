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
  DateTime createdAt;

  UserModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.picture,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    try {
      parsedDate = json['date'] != null ? DateTime.parse(json['date']) : null;
    } catch (e) {
      parsedDate = null; // or set a default value
    }
    return UserModel(
      id: json['_id'] ?? '',
      uid: json['uid'] ?? '',
      name: json['userName'] ?? '',
      email: json['email'] ?? '',
      picture: json['photo'] ?? '',
      createdAt: parsedDate ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'uid': uid,
    'name': name,
    'email': email,
    'picture': picture,
    'createdAt': createdAt.toIso8601String(),
  };
}
