import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:hive/hive.dart';

class Categorierepo {

  static const String _boxName = 'categories';
  static Box<Category>? _box;

  /// Initialize Hive box for local storage
  static Future<void> initializeLocalStorage() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Category>(_boxName);
    }
  }

  /// Get the Hive box
  static Box<Category> get _localBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception(
        'Local storage not initialized. Call initializeLocalStorage() first.',
      );
    }
    return _box!;
  }

  // Local storage 
  Future<void> addCategory(Category category) async {
    await _localBox.add(category);
  }

  Future<List<Category>> getCategories() async {
    return _localBox.values.toList();
  }

  Future<int> getIndexOfCategory(Category category) async {
    return _localBox.values.toList().indexOf(category);
  }

  Future<void> deleteCategory(int index) async {
    await _localBox.deleteAt(index);
  }

  Future<void> updateCategory(int index, Category category) async {
    await _localBox.putAt(index, category);
  }
}