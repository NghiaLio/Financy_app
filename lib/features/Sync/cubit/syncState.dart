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
