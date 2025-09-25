import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:financy_ui/features/Sync/models/pullModels.dart';

void main() {
  test('Pullmodels.fromJson parses provided payload', () {
    final raw = r'''
{
  "status": "success",
  "since": "null",
  "data": {
    "transactions": [
      {
        "_id": "68c639d1d72d7b6e368d509a",
        "uid": "IiKOog1ZqMRYGkruEo8bOxXgVO52",
        "accountId": "f95360e6-9835-4173-b94f-f883c800f274",
        "categoriesId": "Ăn uống",
        "type": "expense",
        "amount": 40000,
        "note": "",
        "transactionDate": "2025-09-14T03:39:13.859Z",
        "createdAt": "2025-09-14T03:39:13.860Z",
        "updatedAt": "2025-09-14T03:43:13.552Z",
        "__v": 0
      }
    ],
    "accounts": [
      {
        "_id": "68c63b4b7f324939d8f5feba",
        "accountName": "Vietcombank",
        "balance": 0,
        "type": "cash",
        "currency": "vnd",
        "iconCode": null,
        "color": "0xFF007AC3",
        "description": "goc",
        "isActive": true,
        "uid": "IiKOog1ZqMRYGkruEo8bOxXgVO52",
        "updatedAt": "2025-09-14T03:49:31.691Z",
        "createdAt": "2025-09-14T03:49:31.690Z",
        "__v": 0
      }
    ],
    "categories": [
      {
        "_id": "68c639d1d72d7b6e368d50a0",
        "uid": "IiKOog1ZqMRYGkruEo8bOxXgVO52",
        "name": "Cho NY",
        "type": "expense",
        "icon": "favorite",
        "color": "0xFFE91E63",
        "updatedAt": "2025-09-14T03:43:13.556Z",
        "createdAt": "2025-09-14T03:43:13.555Z",
        "__v": 0
      }
    ],
    "users": [
      {
        "_id": "68c637ec680a01fbbcab6288",
        "uid": "IiKOog1ZqMRYGkruEo8bOxXgVO52",
        "name": "Nghia Lio",
        "email": "thuynguyenvnvtvp@gmail.com",
        "picture": "/data/user/0/com.example.financy_ui/app_flutter/google_profile_1757820908584.jpg",
        "dateOfBirth": "2004-01-02T17:00:00.000Z",
        "createdAt": "2025-09-14T03:35:08.953Z",
        "updatedAt": "2025-09-14T03:39:58.212Z",
        "__v": 0,
        "refreshToken": "6505a414-2c85-4e84-8e30-0e542dc8cec2"
      }
    ]
  },
  "counts": {
    "transactions": 3,
    "accounts": 2,
    "categories": 1,
    "users": 1
  },
  "lastSync": "Sun Sep 14 2025"
}
''';

    final Map<String, dynamic> map = jsonDecode(raw);
    final pm = Pullmodels.fromJson(map);

    expect(pm.status, 'success');
    // since is provided as "null" string, it should be parsed as null
    expect(pm.since, isNull);
    expect(pm.data, isNotNull);
    expect(pm.data!['server']?.transactions, isNotNull);
    expect(pm.data!['server']?.accounts, isNotNull);
  });
}
