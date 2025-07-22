// ignore_for_file: file_names



import 'package:financy_ui/features/Account/models/money_source.dart';

enum ManageMoneyStatus {loading, loaded,error, success}

class ManageMoneyState {
  final List<MoneySource>? listAccounts;
  ManageMoneyStatus status;
  String? message;
  ManageMoneyState({ this.listAccounts, required this.status, this.message});

  factory ManageMoneyState.loading() => ManageMoneyState(status: ManageMoneyStatus.loading);
  factory ManageMoneyState.loaded(List<MoneySource> listData) => ManageMoneyState(status: ManageMoneyStatus.loaded, listAccounts: listData);
  factory ManageMoneyState.error(String errMess)=> ManageMoneyState(status: ManageMoneyStatus.error, message: errMess);
  factory ManageMoneyState.success(String message) => ManageMoneyState(status: ManageMoneyStatus.success, message: message);
}