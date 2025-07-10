import 'package:financy_ui/features/auth/cubits/authState.dart';
import 'package:financy_ui/features/auth/models/userModels.dart';
import 'package:financy_ui/features/auth/repository/authRepo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authcubit extends Cubit<Authstate> {
  Authcubit() : super(initialAuth());
  
  final Authrepo _authrepo = Authrepo();
  Usermodels? _currentUserGG;

  Usermodels? get currentUserGG => _currentUserGG;

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> sendSaveIdToken()async{
    final credentialUser = await signInWithGoogle();
    final idToken = await credentialUser.user!.getIdToken();
    await _authrepo.ssIdToken(idToken!);
  }

  Future<Usermodels> login() async{
    emit(loadingAuth());
    final res = await _authrepo.authenticated();
    final currentUser = Usermodels.fromJson(res);
    _currentUserGG = currentUser;
    emit(Auth(true));
    return currentUser;
  }
}
