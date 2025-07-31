// ignore_for_file: file_names

import 'package:financy_ui/features/Users/models/userModels.dart';

enum UserStatus {initial, loading, success, error}

class UserState {
  final UserStatus status;
  final UserModel? user;
  final String? error;

  UserState({required this.status, this.user, this.error});

  factory UserState.initial() => UserState(status: UserStatus.initial);
  factory UserState.loading() => UserState(status: UserStatus.loading);
  factory UserState.success(UserModel? user) => UserState(status: UserStatus.success, user: user);
  factory UserState.error(String error) => UserState(status: UserStatus.error, error: error);

}