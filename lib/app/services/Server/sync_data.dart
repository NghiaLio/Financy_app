import 'dart:convert';
import 'package:financy_ui/core/utils/logger.dart';

import 'package:dio/dio.dart';
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
    final syncDataObject = {
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

    debugLog('Sync data object: $syncDataObject');

    // Create FormData with JSON stringified in 'data' field
    final formData = FormData.fromMap({
      'data': jsonEncode(syncDataObject),
      // Add images field here if needed in the future
      // 'images': [
      //   await MultipartFile.fromFile('./path/to/image.png', filename: 'avatar.png')
      // ],
    });

    final result = await _apiService.post('/sync', data: formData);

    debugLog('Sync result: $result');

    return result;
  }

  Future fetchData() async {
    final sinceValue = Hive.box('settings').get('lastSync');
    _apiService.setToken(jwtbox.get('accessToken'));

    // Build query parameters with optional 'since' in ISO8601 format
    Map<String, dynamic> queryParams = {};
    if (sinceValue != null) {
      String? sinceISO;
      if (sinceValue is int) {
        // Convert milliseconds to ISO8601
        sinceISO =
            DateTime.fromMillisecondsSinceEpoch(
              sinceValue,
            ).toUtc().toIso8601String();
      } else if (sinceValue is String) {
        sinceISO = sinceValue; // already ISO8601
      }
      if (sinceISO != null) {
        queryParams['since'] = sinceISO;
      }
    }

    final result = await _apiService.get('/pull', queryParameters: queryParams);
    debugLog('Fetch result: ${result.data}');

    // Parse 'since' from response and save as ISO8601 string
    final responseSince = result.data['since'];
    if (responseSince != null && responseSince is String) {
      Hive.box('settings').put('lastSync', responseSince);
      debugLog('Updated lastSync to: $responseSince');
    } else {
      // Fallback: use current time in ISO8601
      final currentTime = DateTime.now().toUtc().toIso8601String();
      Hive.box('settings').put('lastSync', currentTime);
      debugLog('No valid since from server, using current time: $currentTime');
    }
    return result;
  }
}
