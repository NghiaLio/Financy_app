// ignore_for_file: file_names

import 'dart:developer';

import 'package:financy_ui/features/auth/cubits/authState.dart';
import 'package:financy_ui/features/auth/repository/authRepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Authcubit extends Cubit<Authstate> {
  Authcubit() : super(Authstate.unAuthenticated());

  final Authrepo _authrepo = Authrepo();

  Future<void> login() async {
    try {
      final credentialUser = await _authrepo.signInWithGoogle();
      final idToken = await credentialUser.user!.getIdToken();
      await _authrepo.loginWithGoogle(idToken!);
      emit(Authstate.authenticated());
    } catch (e) {
      log(e.toString());
      emit(Authstate.error(e.toString()));
    }
  }

  Future<void> loginWithNoAccount() async {
    try {
      await _authrepo.loginWithNoAccount();
      emit(Authstate.authenticated());
    } catch (e) {
      emit(Authstate.error(e.toString()));
    }
  }
}
