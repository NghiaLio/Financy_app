// ignore_for_file: file_names
import 'package:financy_ui/features/Users/models/userModels.dart';

enum AuthStatus {unAuthenticated , guest, authenticated,error}

class Authstate {

  final AuthStatus authStatus;
  final UserModel? user;

  final String? errorMessage;

  Authstate({required this.authStatus, this.user, this.errorMessage});

  factory Authstate.unAuthenticated() => Authstate(authStatus: AuthStatus.unAuthenticated);
  factory Authstate.authenticated(UserModel? currentUser) => Authstate(authStatus:AuthStatus.authenticated, user: currentUser);
  factory Authstate.error(String message) => Authstate(authStatus: AuthStatus.error, user: null, errorMessage: message);
}
