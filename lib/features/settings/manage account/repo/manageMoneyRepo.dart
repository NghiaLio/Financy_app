// ignore: file_names
// ignore: file_names
// ignore: file_names
// ignore_for_file: file_names, duplicate_ignore

import 'package:financy_ui/app/services/dio_client.dart';
import '../models/money_source.dart';
import 'package:hive/hive.dart';

class ManageMoneyRepo {
  Future<void> addMoneySource(MoneySource source) async {
    // Implementation for adding a money source
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
