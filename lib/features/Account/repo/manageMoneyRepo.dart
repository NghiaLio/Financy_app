// ignore_for_file: file_names

import 'package:financy_ui/app/services/Server/dio_client.dart';
import '../models/money_source.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ManageMoneyRepo {
  static const String _boxName = 'money_sources';
  static Box<MoneySource>? _box;

  /// Initialize Hive box for local storage
  static Future<void> initializeLocalStorage() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<MoneySource>(_boxName);
    }
  }

  /// Get the Hive box
  static Box<MoneySource> get _localBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Local storage not initialized. Call initializeLocalStorage() first.');
    }
    return _box!;
  }

  // ==================== LOCAL STORAGE METHODS ====================

  /// Save money source to local storage
  Future<void> saveToLocal(MoneySource source) async {
    await initializeLocalStorage();
    await _localBox.add(source);
  }

  /// Get all money sources from local storage
  List<MoneySource> getAllFromLocal() {
    return _localBox.values.toList();
  }

  /// Get money source by ID from local storage
  MoneySource? getFromLocalById(String id) {
    try {
      return _localBox.values.firstWhere((source) => source.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Update money source in local storage
  Future<void> updateInLocal(MoneySource source) async {
    final index = _localBox.values.toList().indexWhere((s) => s.id == source.id);
    if (index != -1) {
      await _localBox.putAt(index, source);
    }else{
      throw Exception('Account not found');
    }
  }

  /// Delete money source from local storage
  Future<void> deleteFromLocal(String id) async {
    final index = _localBox.values.toList().indexWhere((source) => source.id == id);
    if (index != -1) {
      await _localBox.deleteAt(index);
    }else{
      throw Exception('Account not found');
    }
  }

  /// Get active money sources from local storage
  List<MoneySource> getActiveFromLocal() {
    return _localBox.values.where((source) => source.isActive).toList();
  }

  /// Get money sources by type from local storage
  List<MoneySource> getByTypeFromLocal(TypeMoney type) {
    return _localBox.values.where((source) => source.type == type).toList();
  }

  /// Get total balance from local storage
  double getTotalBalanceFromLocal() {
    return _localBox.values.fold(0.0, (sum, source) => sum + source.balance);
  }

  /// Get active total balance from local storage
  double getActiveTotalBalanceFromLocal() {
    return _localBox.values
        .where((source) => source.isActive)
        .fold(0.0, (sum, source) => sum + source.balance);
  }

  /// Clear all local data
  Future<void> clearLocalData() async {
    await _localBox.clear();
  }

  /// Get current account name by id from local storage
  String? getCurrentAccountNameById(String id) {
    return _localBox.values.firstWhere((source) => source.id == id).name;
  }

  // ==================== SERVER API METHODS ====================

  Future<MoneySource?> addMoneySource(MoneySource source) async {
    final accessToken = Hive.box('jwt').get('accessToken');
    ApiService().setToken(accessToken);
    final res = await ApiService().post('/accounts', data: source.toJson());
    if(res.statusCode == 201){
      final serverSource = MoneySource.fromJson(res.data);
      // Save to local storage after successful server save
      await saveToLocal(serverSource);
      return serverSource;
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
    // Update local storage after successful server update
    await updateInLocal(source);
  }

  Future<void> deleteMoneySource(String id) async {
    final accessToken = Hive.box('jwt').get('accessToken');
    ApiService().setToken(accessToken);
    final res = await ApiService().delete('/accounts/$id');
    if (res.statusCode != 204) {
      throw Exception(res.data['message'] ?? 'Failed to delete money source');
    }
    // Delete from local storage after successful server delete
    await deleteFromLocal(id);
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
    // Update local storage after successful server update
    await updateInLocal(source);
  }

  Future<List<MoneySource>?> getMoneySources() async {
    final accessToken = Hive.box('jwt').get('accessToken');
    ApiService().setToken(accessToken);
    final res = await ApiService().get('/accounts');
    if (res.statusCode == 200) {
      final List<dynamic> data = res.data;
      final serverSources = data.map((item) => MoneySource.fromJson(item)).toList();
      
      // Sync with local storage
      await _syncWithLocal(serverSources);
      
      return serverSources;
    }
    return null;
  }

  // ==================== HYBRID METHODS ====================

  /// Get money sources with offline-first approach
  Future<List<MoneySource>> getMoneySourcesOfflineFirst() async {
    // First try to get from local storage
    final localSources = getAllFromLocal();
    
    if (localSources.isNotEmpty) {
      // Return local data immediately
      return localSources;
    }
    
    // If no local data, try to fetch from server
    try {
      final serverSources = await getMoneySources();
      return serverSources ?? [];
    } catch (e) {
      // If server fails, return empty list
      return [];
    }
  }

  /// Add money source with offline support
  Future<MoneySource?> addMoneySourceOffline(MoneySource source) async {
    // First save to local storage
    await saveToLocal(source);
    
    // Then try to sync with server
    try {
      return await addMoneySource(source);
    } catch (e) {
      // If server fails, keep local data and return it
      return source;
    }
  }

  /// Update money source with offline support
  Future<void> updateMoneySourceOffline(MoneySource source) async {
    // First update local storage
    await updateInLocal(source);
    
    // Then try to sync with server
    try {
      await updateMoneySource(source);
    } catch (e) {
      // If server fails, local data is already updated
      throw Exception('Updated locally but failed to sync with server: ${e.toString()}');
    }
  }

  /// Sync local data with server data
  Future<void> _syncWithLocal(List<MoneySource> serverSources) async {
    await initializeLocalStorage();
    
    // Clear existing local data
    await _localBox.clear();
    
    // Add server data to local storage
    for (final source in serverSources) {
      await _localBox.add(source);
    }
  }

  /// Sync local changes to server (for offline changes)
  Future<void> syncLocalChangesToServer() async {
    final localSources = getAllFromLocal();
    
    for (final source in localSources) {
      try {
        // Check if source exists on server
        final existingSource = await _getServerSourceById(source.id!);
        if (existingSource != null) {
          // Update existing source
          await updateMoneySource(source);
        } else {
          // Create new source
          await addMoneySource(source);
        }
      } catch (e) {
        // Log error but continue with other sources
      }
    }
  }

  /// Get single source from server by ID
  Future<MoneySource?> _getServerSourceById(String id) async {
    try {
      final accessToken = Hive.box('jwt').get('accessToken');
      ApiService().setToken(accessToken);
      final res = await ApiService().get('/accounts/$id');
      if (res.statusCode == 200) {
        return MoneySource.fromJson(res.data);
      }
    } catch (e) {
      // Source doesn't exist on server
    }
    return null;
  }

  /// Close local storage
  static Future<void> closeLocalStorage() async {
    await _box?.close();
    _box = null;
  }
}
