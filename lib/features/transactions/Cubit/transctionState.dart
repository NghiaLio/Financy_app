// ignore_for_file: file_names

import 'package:financy_ui/features/transactions/models/transactionsModels.dart';

enum TransactionStateStatus { initial, loading, loaded, success, error }

class TransactionState {
  final Map<DateTime, List<Transactionsmodels>> transactionsList;
  final String? errorMessage;
  final TransactionStateStatus status;

  TransactionState({
    required this.transactionsList,
    this.errorMessage,
    required this.status,
  });

  factory TransactionState.initial() {
    return TransactionState(
      transactionsList: {},
      errorMessage: null,
      status: TransactionStateStatus.initial,
    );
  }
  factory TransactionState.loading() {
    return TransactionState(
      transactionsList: {},
      errorMessage: null,
      status: TransactionStateStatus.loading,
    );
  }
  factory TransactionState.loaded(
    Map<DateTime, List<Transactionsmodels>> transactions,
  ) {
    return TransactionState(
      transactionsList: transactions,
      errorMessage: null,
      status: TransactionStateStatus.loaded,
    );
  }
  factory TransactionState.error(String message) {
    return TransactionState(
      transactionsList: {},
      errorMessage: message,
      status: TransactionStateStatus.error,
    );
  }
  factory TransactionState.success() {
    return TransactionState(
      transactionsList: {},
      errorMessage: null,
      status: TransactionStateStatus.success,
    );
  }
}
