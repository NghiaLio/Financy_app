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

  factory TransactionState.initial() => TransactionState(
    transactionsList: {},
    errorMessage: null,
    status: TransactionStateStatus.initial,
  );

  factory TransactionState.loading() => TransactionState(
    transactionsList: {},
    errorMessage: null,
    status: TransactionStateStatus.loading,
  );

  factory TransactionState.loaded(
    Map<DateTime, List<Transactionsmodels>> transactions,
  ) => TransactionState(
    transactionsList: transactions,
    errorMessage: null,
    status: TransactionStateStatus.loaded,
  );

  factory TransactionState.error(String message) => TransactionState(
    transactionsList: {},
    errorMessage: message,
    status: TransactionStateStatus.error,
  );

  factory TransactionState.success() => TransactionState(
    transactionsList: {},
    errorMessage: null,
    status: TransactionStateStatus.success,
  );
}
