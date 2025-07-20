// ignore_for_file: file_names

import 'package:financy_ui/features/settings/manage_account/cubit/manageMoneyState.dart';
import 'package:financy_ui/features/settings/manage_account/repo/manageMoneyRepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/features/settings/manage_account/models/money_source.dart';

class ManageMoneyCubit extends Cubit<ManageMoneyState>{
  final ManageMoneyRepo _manageMoneyRepo = ManageMoneyRepo();

  ManageMoneyCubit() :super(ManageMoneyState.loading());

  // get accounts 
  Future<void> getAllAccount() async{
    try {
      final List<MoneySource> listAccount = (await _manageMoneyRepo.getMoneySources())?.cast<MoneySource>() ?? [];
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
  
}