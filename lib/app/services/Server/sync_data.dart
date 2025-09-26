import 'dart:developer';

import 'package:financy_ui/app/services/Server/dio_client.dart';
import 'package:financy_ui/features/Account/models/money_source.dart';
import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:financy_ui/features/Users/models/userModels.dart';
import 'package:financy_ui/features/transactions/models/transactionsModels.dart';
import 'package:hive/hive.dart';

class SyncDataService {
  final ApiService _apiService = ApiService();
  final jwtbox = Hive.box('jwt');

  // Your service methods go here
  Future syncData(
    UserModel? boxUser,
    List<MoneySource> accountsData,
    List<Transactionsmodels> transactionsData,
    List<Category> categoriesData,
  ) async {
    // send to server
    _apiService.setToken(jwtbox.get('accessToken'));
    final data = {
      'uid': boxUser?.uid ?? '',
      'users':
          boxUser?.pendingSync == false || boxUser?.pendingSync == null
              ? [boxUser?.toJson()]
              : [],
      'accounts': accountsData.map((account) => account.toJson()).toList(),
      'transactions':
          transactionsData.map((transaction) => transaction.toJson()).toList(),
      'categories':
          categoriesData.map((category) => category.toJson()).toList(),
    };
    log('Sync result: $data');
    final result = await _apiService.post('/sync', data: data);

    log('Sync result: $result');

    return result;
  }

  Future fetchData() async {
    final since = Hive.box('settings').get('lastSync');
    final boxUser = Hive.box<UserModel>('userBox').get('currentUser');
    _apiService.setToken(jwtbox.get('accessToken'));
    final result = await _apiService.get(
      '/sync',
      queryParameters: {'since': since.toString(), 'uid': boxUser?.uid ?? ''},
    );
    log('Fetch result: ${result.data}');

    int lastSyncValue;
    if (result.data['lastSync'] is int) {
      lastSyncValue = result.data['lastSync'];
    } else if (result.data['lastSync'] is String) {
      lastSyncValue =
          int.tryParse(result.data['lastSync']) ??
          DateTime.now().millisecondsSinceEpoch;
    } else {
      lastSyncValue = DateTime.now().millisecondsSinceEpoch;
    }
    Hive.box('settings').put('lastSync', lastSyncValue);
    return result;
  }
}
