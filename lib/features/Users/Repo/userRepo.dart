// ignore_for_file: file_names

import 'package:financy_ui/features/Users/models/userModels.dart';
import 'package:hive/hive.dart';

class UserRepo {
  Future<UserModel?> getUser() async {
    final boxUser = Hive.box<UserModel>('userBox').get('currentUser');
    return boxUser;
  }

  Future<void> updateUser(UserModel user) async {
    await Hive.box<UserModel>('userBox').put('currentUser', user);
  }

  Future<void> deleteUser() async {
    await Hive.box<UserModel>('userBox').delete('currentUser');
  }
}
