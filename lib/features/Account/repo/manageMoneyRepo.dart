// ignore_for_file: file_names

import 'package:financy_ui/app/services/Server/dio_client.dart';
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
    final accessToken = Hive.box('jwt').get('accessToken');
    ApiService().setToken(accessToken);
    final res = await ApiService().put('/accounts/${source.id}', data: source.toJson());
    if (res.statusCode != 200) {
      throw Exception(res.data['message'] ?? 'Failed to update money source');
    }
  }

  Future<void> deleteMoneySource(String id) async {
    final accessToken = Hive.box('jwt').get('accessToken');
    ApiService().setToken(accessToken);
    final res = await ApiService().delete('/accounts/$id');
    if (res.statusCode != 204) {
      throw Exception(res.data['message'] ?? 'Failed to delete money source');
    }
  }

  Future<void> toggleActiveMoneySource(MoneySource source) async {
    final accessToken = Hive.box('jwt').get('accessToken');
    ApiService().setToken(accessToken);
    final res = await ApiService().put(
      '/accounts/${source.id}/active',
      data: source.toJson(),
    );
    if (res.statusCode != 200) {
      throw Exception(res.data['message'] ?? 'Failed to update money source');
    }
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
