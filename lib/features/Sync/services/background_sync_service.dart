// ignore_for_file: unrelated_type_equality_checks, file_names

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:financy_ui/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:financy_ui/features/Account/repo/manageMoneyRepo.dart';
import 'package:financy_ui/features/Categories/repo/categorieRepo.dart';
import 'package:financy_ui/features/Users/Repo/userRepo.dart';
import 'package:financy_ui/features/transactions/repo/transactionsRepo.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:financy_ui/app/services/Local/settings_service.dart';

/// Message types for communication between isolates
class SyncMessage {
  final String type; // 'progress', 'complete', 'error'
  final dynamic data;

  SyncMessage({required this.type, this.data});
}

/// Progress data model
class SyncProgress {
  final String stage; // 'preparing', 'uploading', 'complete'
  final int current;
  final int total;
  final String? message;

  SyncProgress({
    required this.stage,
    this.current = 0,
    this.total = 0,
    this.message,
  });
}

/// Data to pass to isolate
class SyncDataPayload {
  final String accessToken;
  final Map<String, dynamic> syncDataObject;
  final int totalItems;

  SyncDataPayload({
    required this.accessToken,
    required this.syncDataObject,
    required this.totalItems,
  });
}

class BackgroundSyncService {
  static Isolate? _syncIsolate;
  static ReceivePort? _receivePort;
  static StreamController<SyncProgress>? _progressController;
  static bool _isSyncing = false;

  /// Get the progress stream
  static Stream<SyncProgress> get progressStream {
    _progressController ??= StreamController<SyncProgress>.broadcast();
    return _progressController!.stream;
  }

  /// Check if sync is running
  static bool get isSyncing => _isSyncing;

  /// Start background sync
  static Future<void> startBackgroundSync() async {
    if (_isSyncing) {
      debugLog('[BackgroundSync] Sync is already running');
      return;
    }

    // Check if user is logged in with Google (not guest mode)
    if (SettingsService.isGuestLogin()) {
      debugLog('[BackgroundSync] User is in guest mode - sync disabled');
      _progressController?.add(
        SyncProgress(
          stage: 'complete',
          message: 'Sync is only available for logged in users',
        ),
      );
      return;
    }

    // Check internet connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      debugLog('[BackgroundSync] No internet connection available');
      _progressController?.add(
        SyncProgress(
          stage: 'complete',
          message: 'No internet connection - sync cancelled',
        ),
      );
      return;
    }

    debugLog(
      '[BackgroundSync] Internet connection detected: $connectivityResult',
    );
    debugLog(
      '[BackgroundSync] User is logged in with Google - proceeding with sync',
    );
    _isSyncing = true;

    try {
      debugLog('[BackgroundSync] Starting in main thread...');

      // Send initial progress
      _progressController?.add(
        SyncProgress(stage: 'preparing', message: 'Preparing data for sync...'),
      );

      // Collect data in main thread (Hive access)
      final userRepo = UserRepo();
      final accountRepo = ManageMoneyRepo();
      final transactionRepo = TransactionsRepo();
      final categoryRepo = Categorierepo();

      final boxUser = await userRepo.getUser();
      final accounts = accountRepo.getAllFromLocal();
      final transactions = transactionRepo.getAllTransactions();
      final categories = await categoryRepo.getCategories();

      debugLog(
        '[BackgroundSync] Loaded data - Accounts: ${accounts.length}, Transactions: ${transactions.length}, Categories: ${categories.length}',
      );

      // Filter pending items
      final pendingAccounts =
          accounts
              .where((a) => a.pendingSync == false || a.pendingSync == null)
              .toList();
      final pendingTransactions =
          transactions
              .where((t) => t.pendingSync == false || t.pendingSync == null)
              .toList();
      final pendingCategories =
          categories
              .where((c) => c.pendingSync == false || c.pendingSync == null)
              .toList();

      final hasPendingUser =
          boxUser?.pendingSync == false || boxUser?.pendingSync == null;

      debugLog(
        '[BackgroundSync] Pending items - User: $hasPendingUser, Accounts: ${pendingAccounts.length}, Transactions: ${pendingTransactions.length}, Categories: ${pendingCategories.length}',
      );

      // Check if there's anything to sync
      if (!hasPendingUser &&
          pendingAccounts.isEmpty &&
          pendingTransactions.isEmpty &&
          pendingCategories.isEmpty) {
        debugLog('[BackgroundSync] No pending data to sync');
        _progressController?.add(
          SyncProgress(stage: 'complete', message: 'No pending data to sync'),
        );
        _cleanup();
        return;
      }

      final totalItems =
          ((hasPendingUser ? 1 : 0) +
              pendingAccounts.length +
              pendingTransactions.length +
              pendingCategories.length);

      // Prepare sync data object
      final syncDataObject = {
        'uid': boxUser?.uid ?? '',
        'users': hasPendingUser ? [boxUser?.toJson()] : [],
        'accounts': pendingAccounts.map((account) => account.toJson()).toList(),
        'transactions':
            pendingTransactions
                .map((transaction) => transaction.toJson())
                .toList(),
        'categories':
            pendingCategories.map((category) => category.toJson()).toList(),
      };

      // Get and validate token before spawning isolate
      var accessToken = Hive.box('jwt').get('accessToken');
      final refreshToken = Hive.box('jwt').get('refreshToken');
      final baseUrl =
          Hive.box('settings').get('baseUrl') ?? 'http://10.0.2.2:2310/api';

      // Try to refresh token if we have refresh token
      if (refreshToken != null) {
        try {
          debugLog('[BackgroundSync] Attempting to refresh token...');
          final dio = Dio(BaseOptions(baseUrl: baseUrl));
          final res = await dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
            options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
          );

          if (res.statusCode == 200 && res.data['accessToken'] != null) {
            accessToken = res.data['accessToken'];
            await Hive.box('jwt').put('accessToken', accessToken);
            debugLog('[BackgroundSync] Token refreshed successfully');
          }
        } catch (e) {
          debugLog('[BackgroundSync] Token refresh failed: $e');
          // Continue with old token, let the sync attempt and fail if needed
        }
      }

      if (accessToken == null || accessToken.toString().isEmpty) {
        debugLog('[BackgroundSync] No access token available');
        _progressController?.add(
          SyncProgress(
            stage: 'complete',
            message: 'No access token - please login again',
          ),
        );
        _cleanup();
        return;
      }

      // Prepare payload for isolate
      final payload = {
        'accessToken': accessToken ?? '',
        'baseUrl': baseUrl,
        'syncDataObject': syncDataObject,
        'totalItems': totalItems,
      };

      _progressController?.add(
        SyncProgress(
          stage: 'uploading',
          current: 0,
          total: totalItems,
          message: 'Uploading $totalItems item${totalItems > 1 ? 's' : ''}...',
        ),
      );

      _receivePort = ReceivePort();

      // Spawn isolate with payload
      _syncIsolate = await Isolate.spawn(_syncIsolateEntry, {
        'sendPort': _receivePort!.sendPort,
        'payload': payload,
      });

      // Listen to messages from isolate
      _receivePort!.listen((message) async {
        if (message is Map && message['type'] != null) {
          switch (message['type']) {
            case 'progress':
              if (message['data'] is Map) {
                _progressController?.add(
                  SyncProgress(
                    stage: message['data']['stage'],
                    current: message['data']['current'],
                    total: message['data']['total'],
                    message: message['data']['message'],
                  ),
                );
              }
              break;
            case 'complete':
              debugLog(
                '[BackgroundSync] Sync completed, updating local data...',
              );

              // Mark items as synced in main thread
              if (hasPendingUser && boxUser != null) {
                boxUser.pendingSync = true;
                await userRepo.updateUser(boxUser);
              }

              for (final account in pendingAccounts) {
                account.pendingSync = true;
                await accountRepo.updateInLocal(account);
              }

              for (final transaction in pendingTransactions) {
                transaction.pendingSync = true;
                await transactionRepo.updateInLocal(transaction);
              }

              for (final category in pendingCategories) {
                category.pendingSync = true;
                final index = await categoryRepo.getIndexOfCategory(category);
                if (index >= 0) {
                  await categoryRepo.updateCategory(index, category);
                }
              }

              // Update last sync time
              final currentTime = DateTime.now().toUtc().toIso8601String();
              await Hive.box('settings').put('lastSync', currentTime);

              debugLog('[BackgroundSync] All data marked as synced');
              _progressController?.add(
                SyncProgress(
                  stage: 'complete',
                  message: 'Successfully synced $totalItems items',
                ),
              );
              _cleanup();
              break;
            case 'error':
              debugLog('[BackgroundSync] Error: ${message['data']}');
              _progressController?.addError(message['data'] ?? 'Sync failed');
              _cleanup();
              break;
          }
        }
      });
    } catch (e) {
      debugLog('[BackgroundSync] Error starting background sync: $e');
      _progressController?.addError('Failed to start sync: $e');
      _cleanup();
    }
  }

  /// Isolate entry point - only handles API call
  static Future<void> _syncIsolateEntry(Map<String, dynamic> params) async {
    final SendPort sendPort = params['sendPort'];
    final Map<String, dynamic> payload = params['payload'];

    try {
      debugLog('[BackgroundSync] Isolate started, uploading to server...');

      final accessToken = payload['accessToken'] as String;
      final baseUrl = payload['baseUrl'] as String;
      final syncDataObject = payload['syncDataObject'] as Map<String, dynamic>;
      final totalItems = payload['totalItems'] as int;

      debugLog('[BackgroundSync] Using baseUrl: $baseUrl');
      debugLog('[BackgroundSync] Token length: ${accessToken.length}');
      debugLog(
        '[BackgroundSync] Token prefix: ${accessToken.length > 20 ? accessToken.substring(0, 20) : accessToken}...',
      );
      debugLog(
        '[BackgroundSync] Syncing: ${syncDataObject['users']?.length ?? 0} users, ${syncDataObject['accounts']?.length ?? 0} accounts, ${syncDataObject['transactions']?.length ?? 0} transactions, ${syncDataObject['categories']?.length ?? 0} categories',
      );

      // Create Dio client for API call (no Hive needed)
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      sendPort.send({
        'type': 'progress',
        'data': {
          'stage': 'uploading',
          'current': 0,
          'total': totalItems,
          'message': 'Connecting to server...',
        },
      });

      // Prepare FormData
      final formData = FormData.fromMap({'data': jsonEncode(syncDataObject)});

      // Make API call
      final response = await dio.post(
        '/sync',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          // Don't set Content-Type, let Dio handle it for FormData
        ),
      );

      debugLog('[BackgroundSync] Server response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Send progress updates
        for (int i = 1; i <= totalItems; i++) {
          sendPort.send({
            'type': 'progress',
            'data': {
              'stage': 'uploading',
              'current': i,
              'total': totalItems,
              'message': 'Uploaded $i of $totalItems items',
            },
          });
          await Future.delayed(const Duration(milliseconds: 50));
        }

        sendPort.send({
          'type': 'complete',
          'data': 'Successfully uploaded $totalItems items',
        });
      } else {
        debugLog(
          '[BackgroundSync] Upload failed - Status: ${response.statusCode}',
        );
        sendPort.send({
          'type': 'error',
          'data': 'Upload failed: Server returned ${response.statusCode}',
        });
      }
    } catch (e, stackTrace) {
      // Enhanced error logging for DioException
      String errorDetail = e.toString();
      if (e is DioException) {
        final response = e.response;
        debugLog(
          '[BackgroundSync] DioException - Status: ${response?.statusCode}',
        );
        debugLog('[BackgroundSync] Response data: ${response?.data}');
        debugLog('[BackgroundSync] Response headers: ${response?.headers}');

        if (response?.statusCode == 403) {
          errorDetail =
              'Authentication failed (403) - Token may be expired or invalid. Response: ${response?.data}';
        } else {
          errorDetail =
              'Upload failed (${response?.statusCode}): ${response?.data}';
        }
      }

      debugLog('[BackgroundSync] Error in isolate: $e\n$stackTrace');
      sendPort.send({'type': 'error', 'data': errorDetail});
    }
  }

  /// Cleanup resources
  static void _cleanup() {
    _isSyncing = false;
    _syncIsolate?.kill(priority: Isolate.immediate);
    _syncIsolate = null;
    _receivePort?.close();
    _receivePort = null;
  }

  /// Stop sync and cleanup
  static void stopSync() {
    _cleanup();
    _progressController?.add(
      SyncProgress(stage: 'complete', message: 'Sync stopped'),
    );
  }

  /// Dispose resources
  static void dispose() {
    _cleanup();
    _progressController?.close();
    _progressController = null;
  }
}
