// ignore_for_file: file_names

import 'package:financy_ui/features/Users/Cubit/userState.dart';
import 'package:financy_ui/features/Users/Repo/userRepo.dart';
import 'package:financy_ui/features/Users/models/userModels.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserState.initial());

  final UserRepo _userRepository = UserRepo();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<void> getUser() async {
    emit(UserState.loading());
    try {
      final user = await _userRepository.getUser();
      _currentUser = user;
      emit(UserState.success(user));
    } catch (e) {
      emit(UserState.error(e.toString()));
    }
  }

  Future<void> updateUser(UserModel user) async {
    emit(UserState.loading());
    try {
      await _userRepository.updateUser(user);
      _currentUser = user;
      emit(UserState.success(user));
    } catch (e) {
      emit(UserState.error(e.toString()));
    }
  }
}