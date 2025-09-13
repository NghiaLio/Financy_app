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
  String? updatedAt;

  @HiveField(10)
  bool? isDeleted;

  @HiveField(11)
  bool? pendingSync;

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
    this.updatedAt,
    this.isDeleted,
    this.pendingSync,
  });

  /// Factory constructor for backend data (no icon/color)
  factory Transactionsmodels.fromJson(Map<String, dynamic> json) {
    DateTime? txnDate;
    final txnRaw = json['transactionDate'];
    if (txnRaw is int) {
      txnDate = DateTime.fromMillisecondsSinceEpoch(txnRaw);
    } else if (txnRaw is String) {
      txnDate = DateTime.tryParse(txnRaw);
    } else if (txnRaw is DateTime) {
      txnDate = txnRaw;
    }

    DateTime? createdAt;
    final createdRaw = json['createdAt'];
    if (createdRaw is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdRaw);
    } else if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw);
    } else if (createdRaw is DateTime) {
      createdAt = createdRaw;
    }

    return Transactionsmodels(
      id: json['id']?.toString() ?? '',
      uid: json['uid']?.toString() ?? '',
      accountId: json['accountId']?.toString() ?? '',
      categoriesId: json['categoriesId']?.toString() ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
        orElse: () => TransactionType.expense,
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      note: json['note']?.toString(),
      transactionDate: txnDate,
      createdAt: createdAt,
      updatedAt: json['updatedAt']?.toString(),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'accountId': accountId,
      'categoriesId': categoriesId,
      'type': type.toString().split('.').last,
      'amount': amount,
      'note': note,
      'transactionDate': transactionDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'pendingSync': pendingSync,
      'isDeleted': isDeleted ?? false,
      'updatedAt': updatedAt,
    };
  }
}
