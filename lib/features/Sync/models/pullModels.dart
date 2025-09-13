import 'package:financy_ui/features/Account/models/money_source.dart';
import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:financy_ui/features/Sync/models/syncModels.dart';
import 'package:financy_ui/features/Users/models/userModels.dart';
import 'package:financy_ui/features/transactions/models/transactionsModels.dart';

class Pullmodels {
  String? status;
  DateTime? since;
  Map<String, Syncmodels>? data;
  Pullmodels({this.status, this.since, this.data});

  factory Pullmodels.fromJson(Map<String, dynamic> json) {
    int sinceInt;
    if (json['since'] is int) {
      sinceInt = json['since'];
    } else if (json['since'] is String) {
      sinceInt = int.tryParse(json['since']) ?? 0;
    } else {
      sinceInt = 0;
    }
    // parse since: treat explicit string "null" as null
    DateTime? since;
    final rawSince = json['since'];
    if (rawSince == null ||
        (rawSince is String && rawSince.toLowerCase() == 'null')) {
      since = null;
    } else if (rawSince is int) {
      since = DateTime.fromMillisecondsSinceEpoch(rawSince);
    } else if (rawSince is String) {
      // try parse as int then as date string
      final tryInt = int.tryParse(rawSince);
      if (tryInt != null) {
        since = DateTime.fromMillisecondsSinceEpoch(tryInt);
      } else {
        try {
          since = DateTime.parse(rawSince);
        } catch (_) {
          since = null;
        }
      }
    } else {
      since = null;
    }

    // helper to convert date-string fields to millis
    List<Map<String, dynamic>> _asList(dynamic v) {
      if (v == null) return [];
      if (v is List) return List<Map<String, dynamic>>.from(v);
      return [];
    }

    Syncmodels _buildSyncmodelsFromMap(Map<String, dynamic> value) {
      // users
      final usersRaw = _asList(value['users']);
      final users =
          usersRaw.map((user) {
            // Normalize date fields: if server provided millis (int) or DateTime,
            // convert to ISO8601 String so downstream fromJson that expects
            // String dates won't fail.
            for (var dateKey in ['createdAt', 'updatedAt', 'dateOfBirth']) {
              final v = user[dateKey];
              if (v is int) {
                user[dateKey] =
                    DateTime.fromMillisecondsSinceEpoch(v).toIso8601String();
              } else if (v is DateTime) {
                user[dateKey] = v.toIso8601String();
              }
              // leave String as-is
            }
            return UserModel.fromJson(user);
          }).toList();

      // accounts
      final accountsRaw = _asList(value['accounts']);
      final accounts =
          accountsRaw.map((account) {
            for (var dateKey in ['createdAt', 'updatedAt']) {
              final v = account[dateKey];
              if (v is int) {
                account[dateKey] =
                    DateTime.fromMillisecondsSinceEpoch(v).toIso8601String();
              } else if (v is DateTime) {
                account[dateKey] = v.toIso8601String();
              }
            }
            return MoneySource.fromJson(account);
          }).toList();

      // transactions
      final transactionsRaw = _asList(value['transactions']);
      final transactions =
          transactionsRaw.map((transaction) {
            for (var dateKey in ['transactionDate', 'createdAt', 'updatedAt']) {
              final v = transaction[dateKey];
              if (v is int) {
                transaction[dateKey] =
                    DateTime.fromMillisecondsSinceEpoch(v).toIso8601String();
              } else if (v is DateTime) {
                transaction[dateKey] = v.toIso8601String();
              }
            }
            return Transactionsmodels.fromJson(transaction);
          }).toList();

      // categories
      final categoriesRaw = _asList(value['categories']);
      final categories =
          categoriesRaw.map((category) {
            for (var dateKey in ['createdAt', 'updatedAt']) {
              final v = category[dateKey];
              if (v is int) {
                category[dateKey] =
                    DateTime.fromMillisecondsSinceEpoch(v).toIso8601String();
              } else if (v is DateTime) {
                category[dateKey] = v.toIso8601String();
              }
            }
            return Category.fromJson(category);
          }).toList();

      return Syncmodels(
        users: users,
        accounts: accounts,
        transactions: transactions,
        categories: categories,
      );
    }

    final dataNode = json['data'];
    Map<String, Syncmodels> mappedData = {};

    if (dataNode is Map<String, dynamic>) {
      // If top-level has keys like 'transactions','users' (single object), build one Syncmodels
      final topKeys = dataNode.keys.toSet();
      if (topKeys.contains('transactions') ||
          topKeys.contains('users') ||
          topKeys.contains('accounts') ||
          topKeys.contains('categories')) {
        mappedData['server'] = _buildSyncmodelsFromMap(
          Map<String, dynamic>.from(dataNode),
        );
      } else {
        // data is a map of keyed sync objects
        dataNode.forEach((k, v) {
          if (v is Map<String, dynamic>) {
            mappedData[k] = _buildSyncmodelsFromMap(
              Map<String, dynamic>.from(v),
            );
          }
        });
      }
    }

    return Pullmodels(status: json['status'], since: since, data: mappedData);
  }
}
