// ignore_for_file: constant_identifier_names, file_names

import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:financy_ui/features/transactions/models/transactionsModels.dart';
import 'package:financy_ui/shared/utils/mappingAI.dart';
import 'package:financy_ui/shared/utils/mappingIcon.dart';



class Entities{
  final String note;
  final double amount;
  final String date;
  
  Entities({
    required this.note,
    required this.amount,
    required this.date,
  });

  Entities copyWith({
    String? note,
    double? amount,
    String? date,
  }) {
    return Entities(
      note: note ?? this.note,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  factory Entities.fromJson(Map<String, dynamic> json) {
    return Entities(
      note: json['NOTE'] ?? '',
      amount: (json['AMOUNT'] as num).toDouble(),
      date: json['DATE'] ?? '',
    );
  }
}

class AiResultModels {
  final TransactionType intent;
  final Entities entities;
  Category? category;
  String? message;
  String? confirmMessage;

  AiResultModels({
    required this.intent,
    required this.entities,
    this.category,
    this.message,
    this.confirmMessage,
  });

  AiResultModels copyWith({
    TransactionType? intent,
    Entities? entities,
    Category? category,
    String? message,
    String? confirmMessage,
  }) {
    return AiResultModels(
      intent: intent ?? this.intent,
      entities: entities ?? this.entities,
      category: category ?? this.category,
      message: message ?? this.message,
      confirmMessage: confirmMessage ?? this.confirmMessage,
    );
  }

  factory AiResultModels.fromJson(Map<String, dynamic> json) {
    return AiResultModels(
      intent: MappingAI().mapIntentToTransactionType(json['intent']),
      entities: Entities.fromJson(json['entities'] ?? {}),
      category: IconMapping.getCategoryByName(json['category'] ?? ''),
      message: json['message'],
      confirmMessage: json['confirmMessage'],
    );
  }
}

class AIRequest{
  final String userInput;
  final bool isConfirm;

  AIRequest({
    required this.userInput,
    required this.isConfirm,
  });

  Map<String, dynamic> toJson() {
    return {
      'userInput': userInput,
      'isConfirm': isConfirm,
    };
  }
}