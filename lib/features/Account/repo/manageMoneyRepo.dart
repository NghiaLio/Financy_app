// ignore_for_file: file_names
import '../models/money_source.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ManageMoneyRepo {
  
  final Box<MoneySource> _localBox = Hive.box<MoneySource>('moneySourceBox');
  /// Save money source to local storage
  Future<void> saveToLocal(MoneySource source) async {
    
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

  MoneySource? getCurrentAccountByName(String name) {
    try {
      return _localBox.values.firstWhere((source) => source.name == name);
    } catch (e) {
      return null;
    }
  }
}