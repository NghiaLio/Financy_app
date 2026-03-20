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

  String? _currentAccountName;
  String? get currentAccountName => _currentAccountName;

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
      source.pendingSync = false;
      await _manageMoneyRepo.saveToLocal(source);
      // Lấy danh sách mới nhất trước, rồi mới emit success với accounts
      final List<MoneySource> latestList = _manageMoneyRepo.getAllFromLocal();
      _listAccounts = latestList;
      emit(ManageMoneyState.success('Account created successfully', accounts: latestList));
    } catch (e) {
      emit(ManageMoneyState.error(e.toString()));
    }
  }

  //update account
  Future<void> updateAccount(MoneySource source) async {
    try {
      source.pendingSync = false;
      await _manageMoneyRepo.updateInLocal(source);
      final List<MoneySource> latestList = _manageMoneyRepo.getAllFromLocal();
      _listAccounts = latestList;
      emit(ManageMoneyState.success('Account updated successfully', accounts: latestList));
    } catch (e) {
      emit(ManageMoneyState.error(e.toString()));
    }
  }

  // delete account
  Future<void> deleteAccount(MoneySource source) async {
    try {
      await _manageMoneyRepo.deleteFromLocal(source.id!);
      // Luôn lấy list mới nhất và đính kèm vào state success
      final List<MoneySource> latestList = _manageMoneyRepo.getAllFromLocal();
      _listAccounts = latestList;
      emit(ManageMoneyState.success('Account deleted successfully', accounts: latestList));
    } catch (e) {
      emit(ManageMoneyState.error(e.toString()));
    }
  }

  // set current account name
  void setCurrentAccountName(String? newId) {
    if (newId != null) {
      _currentAccountName = _manageMoneyRepo.getCurrentAccountNameById(newId);
    }
  }

  MoneySource? getAccountByName(String name) {
    final currentAccount = _manageMoneyRepo.getCurrentAccountByName(name);
    return currentAccount;
  }
}
