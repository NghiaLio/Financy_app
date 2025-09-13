// ignore_for_file: file_names

import 'package:hive/hive.dart';

part 'categoriesModels.g.dart';

@HiveType(typeId: 8) // đảm bảo không trùng với các model khác
class Category extends HiveObject {
  @HiveField(0)
  String id; // từ MongoDB, lưu dưới dạng String

  @HiveField(1)
  String? userId; // null nếu là mặc định

  @HiveField(2)
  String name;

  @HiveField(3)
  String type; // "expense" | "income"

  @HiveField(4)
  String icon;

  @HiveField(5)
  String color;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  String? uid;

  @HiveField(8)
  String? updatedAt;

  @HiveField(9)
  bool? isDeleted;

  @HiveField(10)
  bool? pendingSync;

  Category({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.createdAt,
    required this.color,
    this.uid,
    this.updatedAt,
    this.isDeleted,
    this.pendingSync,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      createdAt:
          json['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
              : DateTime.parse(
                json['createdAt']?.toString() ??
                    DateTime.now().toIso8601String(),
              ),
      uid: json['uid']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted ?? false,
    };
  }
}
