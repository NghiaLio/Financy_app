// ignore_for_file: file_names, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:developer';

import 'package:financy_ui/features/Sync/models/pullModels.dart';
import 'package:financy_ui/features/Sync/repo/syncRepo.dart';
import 'package:financy_ui/features/Sync/services/background_sync_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/app/services/Server/sync_data.dart';
import 'package:financy_ui/features/Sync/cubit/syncState.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:financy_ui/app/services/Server/dio_client.dart';

class SyncCubit extends Cubit<SyncState> {
  final SyncDataService _syncDataService = SyncDataService();
  StreamSubscription? _syncProgressSubscription;

  SyncCubit() : super(BackgroundSyncIdle()) {
    // Listen to background sync progress
    _syncProgressSubscription = BackgroundSyncService.progressStream.listen(
      (progress) {
        emit(
          BackgroundSyncInProgress(
            stage: progress.stage,
            current: progress.current,
            total: progress.total,
            message: progress.message,
          ),
        );

        // If sync is complete, transition to complete state
        if (progress.stage == 'complete') {
          emit(
            BackgroundSyncComplete(
              message: progress.message ?? 'Sync completed',
            ),
          );
          // Return to idle after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (!isClosed) emit(BackgroundSyncIdle());
          });
        }
      },
      onError: (error) {
        emit(SyncFailure(message: error.toString()));
        // Return to idle after error
        Future.delayed(const Duration(seconds: 2), () {
          if (!isClosed) emit(BackgroundSyncIdle());
        });
      },
    );
  }

  @override
  Future<void> close() {
    _syncProgressSubscription?.cancel();
    return super.close();
  }

  final SyncRepo _syncRepo = SyncRepo();

  /// Start background sync (runs in isolate)
  Future<void> startBackgroundSync() async {
    if (BackgroundSyncService.isSyncing) {
      log('Background sync already in progress');
      return;
    }

    try {
      emit(
        BackgroundSyncInProgress(
          stage: 'preparing',
          message: 'Starting background sync...',
        ),
      );
      await BackgroundSyncService.startBackgroundSync();
    } catch (e) {
      emit(SyncFailure(message: 'Failed to start background sync: $e'));
      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) emit(BackgroundSyncIdle());
      });
    }
  }

  /// Legacy manual sync (for compatibility)
  Future<void> syncData() async {
    try {
      emit(SyncLoading());

      final result = await _syncRepo.syncData();

      if (result != null && result.statusCode == 200) {
        emit(SyncSuccess(message: 'Data synchronized successfully'));
      } else {
        // Extract backend 'error' (preferred) or 'message' field if present
        String errorMsg = 'Failed to synchronize data';
        final backendErr = _extractBackendError(result);
        if (backendErr != null) {
          errorMsg = backendErr;
        } else if (result is Exception) {
          // legacy: parse Exception string if it contains JSON
          final err = result.toString();
          if (err.startsWith('Exception: {')) {
            try {
              final jsonStr = err.replaceFirst('Exception: ', '');
              final Map<String, dynamic> json =
                  jsonStr.isNotEmpty
                      ? Map<String, dynamic>.from(jsonDecode(jsonStr))
                      : {};
              errorMsg = json['message']?.toString() ?? jsonStr;
            } catch (_) {
              errorMsg = err;
            }
          } else {
            errorMsg = err;
          }
        }
        emit(SyncFailure(message: errorMsg));
      }
    } catch (e) {
      // Prefer ApiException from ApiService so we can show backend 'error'
      String errorMsg = 'Error: ${e.toString()}';
      if (e is ApiException) {
        final backendErr = _extractBackendError(e.data);
        if (backendErr != null) {
          errorMsg = backendErr;
        } else if (e.data is Map && e.data['message'] != null)
          errorMsg = e.data['message'].toString();
      } else if (e is Exception) {
        final err = e.toString();
        if (err.startsWith('Exception: {')) {
          try {
            final jsonStr = err.replaceFirst('Exception: ', '');
            final Map<String, dynamic> json =
                jsonStr.isNotEmpty
                    ? Map<String, dynamic>.from(jsonDecode(jsonStr))
                    : {};
            errorMsg = json['message']?.toString() ?? jsonStr;
          } catch (_) {
            errorMsg = err;
          }
        } else {
          errorMsg = err;
        }
      }
      emit(SyncFailure(message: errorMsg));
    }
  }

  Future<void> fetchData() async {
    try {
      emit(SyncLoading());

      final result = await _syncDataService.fetchData();
      final Pullmodels? data =
          result != null && result.data != null
              ? Pullmodels.fromJson(result.data)
              : null;
      if (data != null && result.statusCode == 200) {
        // Update local data with fetched server data
        await _syncRepo.updateData(data);
        emit(SyncSuccess(message: 'Data fetched successfully'));
      } else {
        String errorMsg = 'Failed to fetch data from server';
        final backendErr = _extractBackendError(result);
        if (backendErr != null) errorMsg = backendErr;
        emit(SyncFailure(message: errorMsg));
      }
    } catch (e) {
      log('Fetch data error: ${e.toString()}');
      String errorMsg = 'Error: ${e.toString()}';
      if (e is ApiException) {
        final backendErr = _extractBackendError(e.data);
        if (backendErr != null) {
          errorMsg = backendErr;
        } else if (e.data is Map && e.data['message'] != null)
          errorMsg = e.data['message'].toString();
      }
      emit(SyncFailure(message: errorMsg));
    }
  }

  /// Helper: try to extract `error` (preferred) or `message` from various backends.
  String? _extractBackendError(dynamic respOrData) {
    try {
      if (respOrData == null) return null;

      // ApiException carries data directly
      if (respOrData is ApiException) {
        final d = respOrData.data;
        if (d is Map && d['error'] != null) return d['error'].toString();
        if (d is Map && d['message'] != null) return d['message'].toString();
        return null;
      }

      // If it's a Dio Response-like object (map or object with data)
      if (respOrData is Map) {
        if (respOrData['error'] != null) return respOrData['error'].toString();
        if (respOrData['message'] != null) {
          return respOrData['message'].toString();
        }
        return null;
      }

      // If respOrData has a 'data' field (like Response)
      try {
        final dynamic data = (respOrData as dynamic).data;
        if (data is Map) {
          if (data['error'] != null) return data['error'].toString();
          if (data['message'] != null) return data['message'].toString();
        }
      } catch (_) {}

      // If it's a JSON string
      if (respOrData is String) {
        final trimmed = respOrData.trim();
        if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
          final decoded = jsonDecode(trimmed);
          if (decoded is Map && decoded['error'] != null) {
            return decoded['error'].toString();
          }
          if (decoded is Map && decoded['message'] != null) {
            return decoded['message'].toString();
          }
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  DateTime getLastSyncTime() {
    final lastSync = Hive.box('settings').get('lastSync');
    if (lastSync == null) {
      return DateTime.fromMillisecondsSinceEpoch(0).toLocal();
    }

    // Handle both int (milliseconds) and String (ISO8601) formats
    if (lastSync is int) {
      return DateTime.fromMillisecondsSinceEpoch(lastSync).toLocal();
    } else if (lastSync is String) {
      try {
        return DateTime.parse(lastSync).toLocal();
      } catch (_) {
        // Try parsing as milliseconds string
        final millis = int.tryParse(lastSync);
        if (millis != null) {
          return DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
        }
        return DateTime.fromMillisecondsSinceEpoch(0).toLocal();
      }
    }

    return DateTime.fromMillisecondsSinceEpoch(0).toLocal();
  }
}
