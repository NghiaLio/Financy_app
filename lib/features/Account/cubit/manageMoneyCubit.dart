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
      final List<MoneySource> listAccount = await _manageMoneyRepo.getMoneySources() ?? [];
      emit(ManageMoneyState.loaded(listAccount));
    } catch (e) {
      emit(ManageMoneyState.error(e.toString()));
    }
  }

  // create account
  Future<void> createAccount(MoneySource source) async {
    try {
      final result = await _manageMoneyRepo.addMoneySource(source);
      if (result != null) {
        getAllAccount();
        emit(ManageMoneyState.success('Account created successfully'));
      } else {
        emit(ManageMoneyState.error('Failed to create account'));
      }
    } catch (e) {
      emit(ManageMoneyState.error(e.toString()));
    }
  }

  //update account
  Future<void> updateAccount(MoneySource source) async {
    try {
      await _manageMoneyRepo.updateMoneySource(source);
      getAllAccount();
      emit(ManageMoneyState.success('Account updated successfully'));
    } catch (e) {
      emit(ManageMoneyState.error(e.toString()));
    }
  }

  //toggle active account 
  Future<void> toggleAccountActiveStatus(MoneySource source) async {
    try {
      source.isActive = !source.isActive;
      await _manageMoneyRepo.updateMoneySource(source);
      getAllAccount();
      emit(ManageMoneyState.success('Account status updated successfully'));
    } catch (e) {
      emit(ManageMoneyState.error(e.toString()));
    }
  }

  // delete account
  Future<void> deleteAccount(MoneySource source) async {
    try {
      await _manageMoneyRepo.deleteMoneySource(source.id!);
      getAllAccount();
      emit(ManageMoneyState.success('Account deleted successfully'));
    } catch (e) {
      emit(ManageMoneyState.error(e.toString()));
    }
  }
}