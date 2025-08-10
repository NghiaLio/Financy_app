// ignore_for_file: file_names, deprecated_member_use
import 'package:financy_ui/core/constants/colors.dart';
import 'package:financy_ui/core/constants/icons.dart';
import 'package:financy_ui/features/Categories/cubit/CategoriesCubit.dart';
import 'package:financy_ui/features/Categories/cubit/CategoriesState.dart';
import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:financy_ui/shared/utils/color_utils.dart';
import 'package:financy_ui/shared/utils/mappingIcon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseCategoriesScreen extends StatefulWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  State<ExpenseCategoriesScreen> createState() =>
      _ExpenseCategoriesScreenState();
}

class _ExpenseCategoriesScreenState extends State<ExpenseCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Category> expenseCategories = defaultExpenseCategories;
  List<Category> incomeCategories = defaultIncomeCategories;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textLight),
            onPressed: () {
              _showOptionsMenu(context, theme);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textLight,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.textLight,
          indicatorWeight: 2,
          tabs: const [Tab(text: 'Expenses'), Tab(text: 'Income')],
        ),
      ),
      body: BlocConsumer<Categoriescubit, CategoriesState>(
        listener: (context, state) {
          if (state.status == CategoriesStatus.success) {
            setState(() {
              expenseCategories.addAll(state.categoriesExpense);
              incomeCategories.addAll(state.categoriesIncome);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Categories loaded successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.status == CategoriesStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load categories: ${state.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CategoriesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == CategoriesStatus.failure) {
            return Center(
              child: Text(
                'Error loading categories',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          expenseCategories.addAll(state.categoriesExpense);
          incomeCategories.addAll(state.categoriesIncome);
          return Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCategoryGrid(expenseCategories),
                    _buildCategoryGrid(incomeCategories),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryGrid(List<Category> categories) {
    // Add the "+" button at the end
    final categoriesWithAdd = [...categories];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: categoriesWithAdd.length + 1, // +1 for add button
        itemBuilder: (context, index) {
          if (index == categoriesWithAdd.length) {
            return _buildAddButton();
          }
          return _buildCategoryItem(categoriesWithAdd[index]);
        },
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    return GestureDetector(
      onTap: () {
        _onCategorySelected(category);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color:
                    ColorUtils.parseColor(category.color)?.withOpacity(0.1) ??
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconMapping.stringToIcon(category.icon),
                color: ColorUtils.parseColor(category.color),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        _showAddCategoryDialog();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle, color: Colors.blue, size: 50),
            SizedBox(height: 8),
            Text(
              'Add Category',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onCategorySelected(Category category) {
    Navigator.pushNamed(context, '/editCategory', arguments: category);
  }

  void _showOptionsMenu(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.textLight),
                  title: Text(
                    'Edit Categories',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditCategoriesDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.restore,
                    color: AppColors.textLight,
                  ),
                  title: Text(
                    'Restore Default',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showRestoreDefaultDialog();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showAddCategoryDialog() {
    Navigator.pushNamed(context, '/editCategory');
  }

  void _showEditCategoriesDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit categories feature'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showRestoreDefaultDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A3E),
            title: const Text(
              'Restore Default',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Do you want to restore all categories to default?',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Restored default categories'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text(
                  'Restore',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
