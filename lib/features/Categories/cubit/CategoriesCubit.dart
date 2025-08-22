// ignore_for_file: file_names

import 'package:financy_ui/core/constants/icons.dart';
import 'package:financy_ui/features/Categories/cubit/CategoriesState.dart';
import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:financy_ui/features/Categories/repo/categorieRepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Categoriescubit extends Cubit<CategoriesState> {
  Categoriescubit() : super(CategoriesState.initial());
  final Categorierepo _categorierepo = Categorierepo();

  Future<void> loadCategories() async {
    emit(CategoriesState.loading());
    try {
      final categories = await _categorierepo.getCategories();
      if (categories.isEmpty) {
        await addDefaultCategory(defaultExpenseCategories);
        await addDefaultCategory(defaultIncomeCategories);

        emit(
          CategoriesState.loaded(
            defaultExpenseCategories,
            defaultIncomeCategories,
          ),
        );
        return;
      }
      final categoriesExpense =
          categories.where((c) => c.type == 'expense').toList();
      final categoriesIncome =
          categories.where((c) => c.type == 'income').toList();
      emit(CategoriesState.loaded(categoriesExpense, categoriesIncome));
    } catch (e) {
      emit(CategoriesState.failure(e.toString()));
    }
  }

  Future<void> addDefaultCategory(List<Category> listDefaultCategory) async {
    try {
      for (var category in listDefaultCategory) {
        await _categorierepo.addCategory(category);
      }
    } catch (e) {
      emit(CategoriesState.failure(e.toString()));
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _categorierepo.addCategory(category);
      if (category.type == 'income') {
        final categoriesIncome = [...state.categoriesIncome, category];
        emit(
          CategoriesState.success(state.categoriesExpense, categoriesIncome),
        );
        return;
      } else {
        final categoriesExpense = [...state.categoriesExpense, category];
        emit(
          CategoriesState.success(categoriesExpense, state.categoriesIncome),
        );
      }
    } catch (e) {
      emit(CategoriesState.failure(e.toString()));
    }
  }

  Future<void> updateCategory(int index, Category category) async {
    try {
      await _categorierepo.updateCategory(index, category);

      // Reload categories to get the updated state
      await loadCategories();
    } catch (e) {
      emit(CategoriesState.failure(e.toString()));
    }
  }

  Future<void> deleteCategory(int index, Category category) async {
    try {
      await _categorierepo.deleteCategory(index);
      final allCategories = await _categorierepo.getCategories();
      final categoriesExpense =
          allCategories.where((c) => c.type == 'expense').toList();
      final categoriesIncome =
          allCategories.where((c) => c.type == 'income').toList();
      emit(CategoriesState.success(categoriesExpense, categoriesIncome));
    } catch (e) {
      emit(CategoriesState.failure(e.toString()));
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<int> getIndexOfCategory(Category category) async {
    return await _categorierepo.getIndexOfCategory(category);
  }

  Future<void> restoreDefaultCategories() async {
    emit(CategoriesState.loading());
    try {
      // Clear all existing categories
      await _categorierepo.clearAllCategories();
      
      // Add default categories
      await addDefaultCategory(defaultExpenseCategories);
      await addDefaultCategory(defaultIncomeCategories);
      
      // Emit loaded state with default categories
      emit(
        CategoriesState.loaded(
          defaultExpenseCategories,
          defaultIncomeCategories,
        ),
      );
    } catch (e) {
      emit(CategoriesState.failure(e.toString()));
    }
  }
}
