// ignore_for_file: file_names

import 'package:financy_ui/features/auth/models/userModels.dart';

enum AuthStatus {unAuthenticated , guest, authenticated}

class Authstate {

  final AuthStatus authStatus;
  final Usermodels? user;

  Authstate({required this.authStatus, this.user});

  factory Authstate.unAuthenticated() => Authstate(authStatus: AuthStatus.unAuthenticated);
  factory Authstate.guest()=> Authstate(authStatus: AuthStatus.guest);
  factory Authstate.authenticated(Usermodels currentUser) => Authstate(authStatus:AuthStatus.authenticated, user: currentUser);
}
