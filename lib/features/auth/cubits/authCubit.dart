// ignore_for_file: file_names

import 'package:financy_ui/features/auth/cubits/authState.dart';
import 'package:financy_ui/features/Users/models/userModels.dart';
import 'package:financy_ui/features/auth/repository/authRepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Authcubit extends Cubit<Authstate> {
  Authcubit() : super(Authstate.unAuthenticated());
  
  final Authrepo _authrepo = Authrepo();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<void> login()async{
    final credentialUser = await _authrepo.signInWithGoogle();
    final idToken = await credentialUser.user!.getIdToken();
    await _authrepo.loginWithGoogle(idToken!);
  }

  Future<UserModel?> getUser() async{
    final currentUser = await _authrepo.getCurrentUser();
    _currentUser = currentUser;
    emit(Authstate.authenticated(currentUser));
    return currentUser;
  }

  // Future<void> loginWithNoAccount() async{
  //   emit(Authstate.guest());
  // }
}
