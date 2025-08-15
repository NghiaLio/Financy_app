// ignore_for_file: file_names

import 'package:financy_ui/app/services/Server/dio_client.dart';
import 'package:financy_ui/features/Users/models/userModels.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:financy_ui/app/services/Local/settings_service.dart';

class Authrepo {

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

  Future<void> loginWithGoogle(String tokenID) async {
    // fetch token
    final data = {"idToken": tokenID};
    final res = await ApiService().post('google/login', data: data);
    final accessToken = res.data['accessToken'];
    final refreshToken = res.data['refreshToken'];
    //save to local storage
    Hive.box('jwt').put('accessToken', accessToken);
    Hive.box('jwt').put('refreshToken', refreshToken);
    ApiService().setToken(accessToken);
    // fetch user data
    final user = await ApiService().get('/google/user');
    //save user to local storage
    await Hive.box<UserModel>('userBox').put('currentUser', UserModel.fromJson(user.data));
    await SettingsService.setAppState(true);
  }

  Future<Map<String,dynamic>> authenticated() async{
    final accessToken = Hive.box('jwt').get('accessToken');
    ApiService().setToken(accessToken);
    final res = await ApiService().get('/google/user');
    return res.data;
  }

  //get user data from local storage
  Future<UserModel?> getCurrentUser() async{
    final boxUser = Hive.box<UserModel>('userBox').get('currentUser');
    return boxUser;
  }


  //login with no account
  Future<void> loginWithNoAccount(UserModel guestUser) async {
    await Hive.box<UserModel>('userBox').put('currentUser', guestUser);
    await SettingsService.setAppState(true);
  }

}
