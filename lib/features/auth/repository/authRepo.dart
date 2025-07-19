// ignore_for_file: file_names

import 'package:financy_ui/app/services/dio_client.dart';
import 'package:hive_flutter/adapters.dart';

class Authrepo {
  Future<void> ssIdToken(String tokenID) async {
    // fetch token
    final data = {"idToken": tokenID};
    final res = await ApiService().post('google/login', data: data);
    final accessToken = res.data['accessToken'];
    final refreshToken = res.data['refreshToken'];
    //save to local storage
    Hive.box('jwt').put('accessToken', accessToken);
    Hive.box('jwt').put('refreshToken', refreshToken);
  }

  Future<Map<String,dynamic>> authenticated() async{
    final accessToken = Hive.box('jwt').get('accessToken');
    ApiService().setToken(accessToken);
    final res = await ApiService().get('/google/user');
    return res.data;
  }
}
