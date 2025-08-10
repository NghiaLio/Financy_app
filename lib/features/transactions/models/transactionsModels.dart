// ignore_for_file: file_names

import 'package:hive/hive.dart';
part 'transactionsModels.g.dart';

@HiveType(typeId: 6)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}


@HiveType(typeId: 7)
class Transactionsmodels extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String uid;

  @HiveField(2)
  String accountId;

  @HiveField(3)
  String categoriesId;

  @HiveField(4)
  TransactionType type;

  @HiveField(5)
  double amount;

  @HiveField(6)
  String? note; // Store icon as string code instead of IconData

  @HiveField(7)
  DateTime? transactionDate;

  @HiveField(8)
  DateTime? createdAt;

  @HiveField(9)
  bool isSync;

  Transactionsmodels({
    required this.id,
    required this.uid,
    required this.accountId,
    required this.categoriesId,
    required this.type,
    required this.amount,
    this.note,
    this.transactionDate,
    this.createdAt,
    this.isSync = false,
  });

 

  /// Factory constructor for backend data (no icon/color)
  factory Transactionsmodels.fromJson(Map<String, dynamic> json) {
    return Transactionsmodels(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      accountId: json['accountId'] ?? '',
      categoriesId: json['categoriesId'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
        orElse: () => TransactionType.expense,
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      note: json['note'],
      transactionDate: DateTime.tryParse(json['transactionDate'] ?? ''),
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      isSync: json['isSync'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'accountId': accountId,
      'categoriesId': categoriesId,
      'type': type.toString().split('.').last,
      'amount': amount,
      'note': note,
      'transactionDate': transactionDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'isSync': isSync,
    };
  }
}






