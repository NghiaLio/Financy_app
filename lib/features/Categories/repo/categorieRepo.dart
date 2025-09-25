// ignore_for_file: file_names

import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:hive/hive.dart';

class Categorierepo {

  final Box<Category> _localBox = Hive.box<Category>('categoryBox');
  // Local storage 
  Future<void> addCategory(Category category) async {
    await _localBox.add(category);
  }

  Future<List<Category>> getCategories() async {
    return _localBox.values.toList();
  }

  Future<int> getIndexOfCategory(Category category) async {
    final categories = _localBox.values.toList();
    for (int i = 0; i < categories.length; i++) {
      if (categories[i].id == category.id) {
        return i;
      }
    }
    return -1;
  }

  Future<void> deleteCategory(int index) async {
    await _localBox.deleteAt(index);
  }

  Future<void> updateCategory(int index, Category category) async {
    await _localBox.putAt(index, category);
  }

  Future<void> clearAllCategories() async {
    await _localBox.clear();
  }
}