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

  @HiveField(7)
  String? updatedAt;

  @HiveField(8)
  bool? isDeleted;

  @HiveField(9)
  bool? pendingSync;

  UserModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.picture,
    required this.dateOfBirth,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted,
    this.pendingSync,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    DateTime? createdAt;
    // dateOfBirth can be a String ISO date, an int millis, or missing
    final dobRaw = json['dateOfBirth'];
    if (dobRaw is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(dobRaw);
    } else if (dobRaw is String) {
      parsedDate = DateTime.tryParse(dobRaw);
    } else if (dobRaw is DateTime) {
      parsedDate = dobRaw;
    } else {
      parsedDate = null;
    }

    final createdRaw = json['createdAt'];
    if (createdRaw is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdRaw);
    } else if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw);
    } else if (createdRaw is DateTime) {
      createdAt = createdRaw;
    } else {
      createdAt = null;
    }
    return UserModel(
      id: json['_id'] ?? json['id'] ?? json['userId'] ?? '',
      uid: json['uid'] ?? json['userUid'] ?? '',
      name: json['userName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      picture: json['photo'] ?? json['picture'] ?? json['avatar'] ?? '',
      dateOfBirth: parsedDate ?? DateTime.now(),
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: json['updatedAt'],
      isDeleted: json['isDeleted'] ?? false,
      pendingSync: json['pendingSync'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'picture': picture,
    'dateOfBirth': dateOfBirth.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt,
    'isDeleted': isDeleted ?? false,
    'pendingSync': pendingSync,
  };
}
