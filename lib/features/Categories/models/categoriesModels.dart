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



  Category({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.createdAt, required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] as String,
      userId: json['userId'] as String?,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String,dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
