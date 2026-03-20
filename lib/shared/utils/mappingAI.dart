// ignore_for_file: file_names

import 'package:financy_ui/features/transactions/models/transactionsModels.dart';

class MappingAI{
  TransactionType mapIntentToTransactionType(String intent) {
    switch (intent.toLowerCase()) {
      case 'add_expense':
        return TransactionType.expense;
      case 'add_income':
        return TransactionType.income;
      default:
        return TransactionType.expense; // Default to expense if intent is unrecognized
    }
  }
}