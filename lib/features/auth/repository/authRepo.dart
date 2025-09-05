// ignore_for_file: file_names, invalid_return_type_for_catch_error

import 'package:financy_ui/app/services/Server/dio_client.dart';
import 'package:financy_ui/features/Users/models/userModels.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:financy_ui/app/services/Local/settings_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

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
    final res = await ApiService().post('google/login', data: data).catchError((e)=>{
      throw Exception('Login with Google failed: ${e.toString()}')
    });
    if (res.statusCode != 200) {
      throw Exception('Login with Google failed: ${res.statusMessage}');
    }
    final accessToken = res.data['accessToken'];
    final refreshToken = res.data['refreshToken'];
    //save to local storage
    Hive.box('jwt').put('accessToken', accessToken);
    Hive.box('jwt').put('refreshToken', refreshToken);
    ApiService().setToken(accessToken);
    // fetch user data
    final user = await ApiService().get('/google/user');
    // Nếu user có picture là link, tải về app data và lưu path local
    String? localPicturePath;
    if (user.data['photo'] != null &&
        user.data['photo'].toString().startsWith('http')) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final fileName =
            'google_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savePath = '${dir.path}/$fileName';
        await Dio().download(user.data['photo'], savePath);
        localPicturePath = savePath;
      } catch (e) {
        localPicturePath = null;
      }
    }
    // Lưu user vào Hive, thay picture = local path nếu có
    final userJson = Map<String, dynamic>.from(user.data);
    if (localPicturePath != null) {
      userJson['photo'] = localPicturePath;
    }
    await Hive.box<UserModel>(
      'userBox',
    ).put('currentUser', UserModel.fromJson(userJson));
    await SettingsService.setAppState(true);
  }

  Future<Map<String, dynamic>> authenticated() async {
    final accessToken = Hive.box('jwt').get('accessToken');
    ApiService().setToken(accessToken);
    final res = await ApiService().get('/google/user');
    return res.data;
  }

  //get user data from local storage
  Future<UserModel?> getCurrentUser() async {
    final boxUser = Hive.box<UserModel>('userBox').get('currentUser');
    // Nếu picture là local path, trả về luôn, nếu là link thì không cần tải lại
    return boxUser;
  }

  //login with no account
  Future<void> loginWithNoAccount(UserModel guestUser) async {
    await Hive.box<UserModel>('userBox').put('currentUser', guestUser);
    await SettingsService.setAppState(true);
  }
}
