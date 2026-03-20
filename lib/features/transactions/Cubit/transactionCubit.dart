// ignore_for_file: file_names

import 'package:financy_ui/features/transactions/Cubit/transctionState.dart';
import 'package:financy_ui/features/transactions/models/transactionsModels.dart';
import 'package:financy_ui/features/transactions/repo/transactionsRepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(TransactionState.loading());

  final TransactionsRepo _transactionsRepo = TransactionsRepo();

  Future<void> fetchTransactionsByDate() async {
    try {
      emit(TransactionState.loading());
      final transactions = await _transactionsRepo.getAllTransactionByDate();
      emit(TransactionState.loaded(transactions));
    } catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }

  Future<void> fetchTransactionsByAccount(String accountId) async {
    try {
      emit(TransactionState.loading());
      final transactions = await _transactionsRepo.getAllTransactionByAccount(
        accountId,
      );
      emit(TransactionState.loaded(transactions));
    } catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }

  Future<void> addTransaction(Transactionsmodels transaction) async {
    try {
      transaction.pendingSync = false;
      await _transactionsRepo.saveToLocal(transaction);

      // Fetch lại từ Hive theo accountId để đảm bảo data nhất quán
      // (tránh key mismatch khi merge thủ công vào map)
      final accountId = transaction.accountId;
      if (accountId.isNotEmpty) {
        final freshMap = await _transactionsRepo.getAllTransactionByAccount(
          accountId,
        );
        emit(TransactionState.loaded(freshMap));
        emit(
          TransactionState(
            transactionsList: freshMap,
            errorMessage: null,
            status: TransactionStateStatus.success,
          ),
        );
      } else {
        // Fallback: fetch all by date
        final freshMap = await _transactionsRepo.getAllTransactionByDate();
        emit(TransactionState.loaded(freshMap));
        emit(
          TransactionState(
            transactionsList: freshMap,
            errorMessage: null,
            status: TransactionStateStatus.success,
          ),
        );
      }
    } catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }

  Future<void> updateTransaction(Transactionsmodels transaction) async {
    try {
      transaction.pendingSync = false;
      await _transactionsRepo.updateInLocal(transaction);

      // Fetch lại từ Hive để đảm bảo data nhất quán
      final accountId = transaction.accountId;
      if (accountId.isNotEmpty) {
        final freshMap = await _transactionsRepo.getAllTransactionByAccount(
          accountId,
        );
        emit(TransactionState.loaded(freshMap));
        emit(
          TransactionState(
            transactionsList: freshMap,
            errorMessage: null,
            status: TransactionStateStatus.success,
          ),
        );
      } else {
        final freshMap = await _transactionsRepo.getAllTransactionByDate();
        emit(TransactionState.loaded(freshMap));
        emit(
          TransactionState(
            transactionsList: freshMap,
            errorMessage: null,
            status: TransactionStateStatus.success,
          ),
        );
      }
    } catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsRepo.deleteFromLocal(id);

      // Fetch lại tất cả theo ngày (vì delete không biết account)
      final freshMap = await _transactionsRepo.getAllTransactionByDate();
      emit(TransactionState.loaded(freshMap));
      emit(
        TransactionState(
          transactionsList: freshMap,
          errorMessage: null,
          status: TransactionStateStatus.success,
        ),
      );
    } catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }
}
