// ignore_for_file: file_names

import 'package:financy_ui/features/Account/cubit/manageMoneyState.dart';
import 'package:financy_ui/features/Account/repo/manageMoneyRepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/features/Account/models/money_source.dart';

class ManageMoneyCubit extends Cubit<ManageMoneyState>{
  final ManageMoneyRepo _manageMoneyRepo = ManageMoneyRepo();

  ManageMoneyCubit() :super(ManageMoneyState.loading());

  // get accounts 
  Future<void> getAllAccount() async{
    try {
      final List<MoneySource> listAccount = _manageMoneyRepo.getAllFromLocal();
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
      getAllAccount();
    } catch (e) {
      emit(ManageMoneyState.error(e.toString()));
    }
  }

  //update account
  Future<void> updateAccount(MoneySource source) async {
    try {
      await _manageMoneyRepo.updateInLocal(source);
      getAllAccount();
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