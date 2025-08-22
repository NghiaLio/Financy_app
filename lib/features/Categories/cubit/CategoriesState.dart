// ignore_for_file: file_names

import 'package:financy_ui/features/Categories/models/categoriesModels.dart';

enum CategoriesStatus { initial, loading, loaded, failure,success }

class CategoriesState {
  final List<Category> categoriesExpense;
  final List<Category> categoriesIncome;
  final CategoriesStatus status;
  final String errorMessage;

  CategoriesState({
    required this.categoriesExpense,
    required this.categoriesIncome,
    required this.status,
    required this.errorMessage,
  });

  factory CategoriesState.initial() {
    return CategoriesState(
      categoriesExpense: [],
      categoriesIncome: [],
      status: CategoriesStatus.initial,
      errorMessage: '',
    );
  }
  factory CategoriesState.loading() {
    return CategoriesState(
      categoriesExpense: [],
      categoriesIncome: [],
      status: CategoriesStatus.loading,
      errorMessage: '',
    );
  }
  factory CategoriesState.loaded(List<Category> categoriesExpense, List<Category> categoriesIncome) {
    return CategoriesState(
      categoriesExpense: categoriesExpense,
      categoriesIncome: categoriesIncome,
      status: CategoriesStatus.loaded,
      errorMessage: '',
    );
  }

  factory CategoriesState.failure(String errorMessage) {
    return CategoriesState(
      categoriesExpense: [],
      categoriesIncome: [],
      status: CategoriesStatus.failure,
      errorMessage: errorMessage,
    );
  }
  factory CategoriesState.success(List<Category> categoriesExpense, List<Category> categoriesIncome) {
    return CategoriesState(
      categoriesExpense: categoriesExpense,
      categoriesIncome: categoriesIncome,
      status: CategoriesStatus.success,
      errorMessage: '',
    );
  }
}