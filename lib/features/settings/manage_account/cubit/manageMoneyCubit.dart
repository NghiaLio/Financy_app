// ignore_for_file: file_names

import 'package:financy_ui/features/settings/manage_account/cubit/manageMoneyState.dart';
import 'package:financy_ui/manageAccount.dart';
import 'package:financy_ui/features/settings/manage_account/repo/manageMoneyRepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
}