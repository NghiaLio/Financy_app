// ignore_for_file: file_names

abstract class SyncState {}

class SyncInitial extends SyncState {}

class SyncLoading extends SyncState {}

class SyncSuccess extends SyncState {
  final String message;

  SyncSuccess({required this.message});
}

class SyncFailure extends SyncState {
  final String message;

  SyncFailure({required this.message});
}

// Background sync states
class BackgroundSyncInProgress extends SyncState {
  final String stage; // 'preparing', 'uploading', 'complete'
  final int current;
  final int total;
  final String? message;

  BackgroundSyncInProgress({
    required this.stage,
    this.current = 0,
    this.total = 0,
    this.message,
  });

  double get progress => total > 0 ? current / total : 0.0;
}

class BackgroundSyncIdle extends SyncState {}

class BackgroundSyncComplete extends SyncState {
  final String message;

  BackgroundSyncComplete({required this.message});
}
