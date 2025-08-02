// ignore_for_file: file_names

import 'package:financy_ui/features/Account/cubit/manageMoneyState.dart';
import 'package:financy_ui/features/Account/repo/manageMoneyRepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/features/Account/models/money_source.dart';

class ManageMoneyCubit extends Cubit<ManageMoneyState> {
  final ManageMoneyRepo _manageMoneyRepo = ManageMoneyRepo();

  ManageMoneyCubit() : super(ManageMoneyState.loading());

  List<MoneySource>? _listAccounts;
  List<MoneySource>? get listAccounts => _listAccounts;

  // get accounts
  Future<void> getAllAccount() async {
    try {
      final List<MoneySource> listAccount = _manageMoneyRepo.getAllFromLocal();
      _listAccounts = listAccount;
      emit(ManageMoneyState.loaded(listAccount));
    } catch (e) {
      emit(ManageMoneyState.error(e.toString()));
    }
  }

  // create account
  Future<void> createAccount(MoneySource source) async {
    try {
      await _manageMoneyRepo.saveToLocal(source);
      emit(ManageMoneyState.success('Account created successfully'));
      Future.delayed(const Duration(seconds: 1), () {
        _listAccounts = [...state.listAccounts ?? [], source];
        emit(ManageMoneyState.loaded([...state.listAccounts ?? [], source]));
      });
    } catch (e) {
      emit(ManageMoneyState.error(e.toString()));
    }
  }

  //update account
  Future<void> updateAccount(MoneySource source) async {
    try {
      await _manageMoneyRepo.updateInLocal(source);
      final updatedList = state.listAccounts?.map((s) => s.id == source.id ? source : s).toList() ?? [];
      _listAccounts = updatedList;
      emit(ManageMoneyState.loaded(updatedList));
      emit(ManageMoneyState.success('Account updated successfully'));
    } catch (e) {
      emit(ManageMoneyState.error(e.toString()));
    }
  }

  // delete account
  Future<void> deleteAccount(MoneySource source) async {
    try {
      await _manageMoneyRepo.deleteFromLocal(source.id!);
      emit(ManageMoneyState.success('Account deleted successfully'));
      getAllAccount();
    } catch (e) {
      emit(ManageMoneyState.error(e.toString()));
    }
  }
}
