// ignore_for_file: file_names

import 'package:financy_ui/features/Users/models/guestModels.dart';
import 'package:financy_ui/features/Users/models/userModels.dart';

enum AuthStatus {unAuthenticated , guest, authenticated}

class Authstate {

  final AuthStatus authStatus;
  final UserModel? user;
  final GuestModel? guest;

  Authstate({required this.authStatus, this.user, this.guest});

  factory Authstate.unAuthenticated() => Authstate(authStatus: AuthStatus.unAuthenticated);
  factory Authstate.guest(GuestModel? currentGuest) => Authstate(authStatus: AuthStatus.guest, guest: currentGuest);
  factory Authstate.authenticated(UserModel? currentUser) => Authstate(authStatus:AuthStatus.authenticated, user: currentUser);
}
