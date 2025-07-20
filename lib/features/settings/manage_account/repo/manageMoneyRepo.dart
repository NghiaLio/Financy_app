// ignore_for_file: file_names

import 'package:financy_ui/app/services/dio_client.dart';
import '../models/money_source.dart';
import 'package:hive/hive.dart';

class ManageMoneyRepo {
  Future<MoneySource?> addMoneySource(MoneySource source) async {
    final accessToken = Hive.box('jwt').get('accessToken');
    ApiService().setToken(accessToken);
    final res = await ApiService().post('/accounts', data: source.toJson());
    if(res.statusCode == 201){
      return MoneySource.fromJson(res.data);
    }
    return null;
  }

  Future<void> updateMoneySource(MoneySource source) async {
    // Implementation for updating a money source
  }

  Future<void> deleteMoneySource(String id) async {
    // Implementation for deleting a money source
  }

  Future<List<MoneySource>?> getMoneySources() async {
    final accessToken = Hive.box('jwt').get('accessToken');
    ApiService().setToken(accessToken);
    final res = await ApiService().get('/accounts');
    if (res.statusCode == 200) {
      final List<dynamic> data = res.data;
      return data.map((item) => MoneySource.fromJson(item)).toList();
    }
    return null;
  }
}
