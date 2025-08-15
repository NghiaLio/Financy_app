// ignore_for_file: file_names, deprecated_member_use, use_build_context_synchronously
import 'package:financy_ui/core/constants/colors.dart';
import 'package:financy_ui/features/Categories/cubit/CategoriesCubit.dart';
import 'package:financy_ui/features/Categories/cubit/CategoriesState.dart';
import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:financy_ui/shared/utils/color_utils.dart';
import 'package:financy_ui/shared/utils/mappingIcon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/app/services/Local/settings_service.dart';

class ExpenseCategoriesScreen extends StatefulWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  State<ExpenseCategoriesScreen> createState() =>
      _ExpenseCategoriesScreenState();
}

class _ExpenseCategoriesScreenState extends State<ExpenseCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _isGridView; // Toggle between grid and list view

  List<Category> expenseCategories = [];
  List<Category> incomeCategories = [];

  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load view mode from settings
    _isGridView = SettingsService.getCategoryViewMode();
    context.read<Categoriescubit>().loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          !isEdit
              ? IconButton(
                icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                onPressed: () {
                  _showOptionsMenu(context, theme);
                },
              )
              : GestureDetector(
                onTap: () {
                  setState(() {
                    isEdit = false;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n?.done ?? 'Done',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.textTheme.bodyMedium?.color,
          unselectedLabelColor: theme.hintColor,
          indicatorColor: theme.primaryColor,
          indicatorWeight: 2,
          tabs: [
            Tab(text: l10n?.expense ?? 'Expense'),
            Tab(text: l10n?.income ?? 'Income'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 6,
        child: Icon(Icons.add, size: 28),
      ),
      body: BlocConsumer<Categoriescubit, CategoriesState>(
        listener: (context, state) async {
          if (state.status == CategoriesStatus.success) {
            expenseCategories = state.categoriesExpense;
            incomeCategories = state.categoriesIncome;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.success ?? 'Success',
                  style: theme.textTheme.bodyMedium,
                ),
                backgroundColor: theme.primaryColor,
              ),
            );
          } else if (state.status == CategoriesStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.error ?? 'Error',
                  style: theme.textTheme.bodyMedium,
                ),
                backgroundColor: theme.colorScheme.error,
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
                l10n?.error ?? 'Error',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            );
          }

          expenseCategories = state.categoriesExpense;
          incomeCategories = state.categoriesIncome;

          return Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _isGridView
                        ? _buildCategoryGridGrouped(expenseCategories)
                        : _buildCategoryListGrouped(expenseCategories),
                    _isGridView
                        ? _buildCategoryGridGrouped(incomeCategories)
                        : _buildCategoryListGrouped(incomeCategories),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildCategoryGridGrouped(List<Category> categories) {
    final groupedCategories = IconMapping.groupCategoriesByType(categories);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: groupedCategories.length,
        itemBuilder: (context, index) {
          final groupEntry = groupedCategories.entries.elementAt(index);
          final groupName = groupEntry.key;
          final groupCategories = groupEntry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                child: Text(
                  groupName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Tăng từ 3 lên 4 items trên 1 hàng
                  crossAxisSpacing: 8, // Giảm từ 12 xuống 8 để vừa 4 items
                  mainAxisSpacing: 8, // Giảm từ 12 xuống 8 để vừa 4 items
                  childAspectRatio:
                      1.0, // Giảm từ 1.2 xuống 1.0 để items vuông hơn
                ),
                itemCount: groupCategories.length,
                itemBuilder: (context, gridIndex) {
                  return _buildCategoryItem(groupCategories[gridIndex]);
                },
              ),
              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryListGrouped(List<Category> categories) {
    final groupedCategories = IconMapping.groupCategoriesByType(categories);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: groupedCategories.length,
        itemBuilder: (context, index) {
          final groupEntry = groupedCategories.entries.elementAt(index);
          final groupName = groupEntry.key;
          final groupCategories = groupEntry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                child: Text(
                  groupName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              ...groupCategories.map(
                (category) => _buildCategoryListItem(category),
              ),
              SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    return GestureDetector(
      onTap: () {
        isEdit ? null : _onCategorySelected(category);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            _buildDeleteButton(category),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40, // Giảm từ 50 xuống 40 (20% giảm)
                    height: 40, // Giảm từ 50 xuống 40 (20% giảm)
                    decoration: BoxDecoration(
                      color:
                          ColorUtils.parseColor(
                            category.color,
                          )?.withOpacity(0.1) ??
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconMapping.stringToIcon(category.icon),
                      color: ColorUtils.parseColor(category.color),
                      size: 22, // Giảm từ 28 xuống 22 (21% giảm)
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCategorySelected(Category category) async {
    final result = await Navigator.pushNamed(
      context,
      '/editCategory',
      arguments: category,
    );

    // Refresh categories if there was an edit/add/delete action
    if (result != null && result is Map<String, dynamic>) {
      context.read<Categoriescubit>().loadCategories();
    }
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
                  leading: Icon(
                    _isGridView ? Icons.view_list : Icons.grid_view,
                    color: theme.iconTheme.color,
                  ),
                  title: Text(
                    _isGridView ? 'List View' : 'Grid View',
                    style: theme.textTheme.bodyLarge,
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                    // Save view mode to settings
                    await SettingsService.setCategoryViewMode(_isGridView);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.edit, color: theme.iconTheme.color),
                  title: Text(
                    AppLocalizations.of(context)?.edit ?? 'Edit categories',
                    style: theme.textTheme.bodyLarge,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _editCategoriesDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.restore, color: theme.iconTheme.color),
                  title: Text(
                    'Restore Default',
                    style: theme.textTheme.bodyLarge,
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

  void _showAddCategoryDialog() async {
    final result = await Navigator.pushNamed(context, '/editCategory');

    // Refresh categories if there was an add action
    if (result != null && result is Map<String, dynamic>) {
      context.read<Categoriescubit>().loadCategories();
    }
  }

  void _editCategoriesDialog() {
    setState(() {
      isEdit = true;
    });
  }

  void _showRestoreDefaultDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardColor,
            title: Text('Restore Default', style: theme.textTheme.titleLarge),
            content: Text(
              'Do you want to restore all categories to default?',
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)?.cancel ?? 'Cancel',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)?.success ?? 'Success',
                        style: theme.textTheme.bodyMedium,
                      ),
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                  );
                },
                child: Text(
                  'Restore',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showDialogConfirmDelete(Category category) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context)?.deleteSource ?? 'Delete Source',
            ),
            content: Text(
              AppLocalizations.of(
                    context,
                  )?.deleteSourceConfirm(category.name) ??
                  'Are you sure you want to delete ${category.name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    () => {_deleteCategory(category), Navigator.pop(context)},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.negativeRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)?.delete ?? 'Delete',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
    // Close the dialog after action
  }

  void _deleteCategory(Category category) async {
    final index = await context.read<Categoriescubit>().getIndexOfCategory(
      category,
    );
    await context.read<Categoriescubit>().deleteCategory(index, category);
  }

  Widget _buildCategoryListItem(Category category) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          _buildDeleteButton(category),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            tileColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: Container(
              width: 43, // Giảm từ 48 xuống 43 (10% giảm)
              height: 43, // Giảm từ 48 xuống 43 (10% giảm)
              decoration: BoxDecoration(
                color:
                    ColorUtils.parseColor(category.color)?.withOpacity(0.1) ??
                    theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconMapping.stringToIcon(category.icon),
                color: ColorUtils.parseColor(category.color),
                size: 22, // Giảm từ 24 xuống 22 (8% giảm)
              ),
            ),
            title: Text(
              category.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              category.type == 'income'
                  ? (AppLocalizations.of(context)?.income ?? 'Income')
                  : (AppLocalizations.of(context)?.expense ?? 'Expense'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: theme.hintColor,
              size: 16,
            ),
            onTap: () => isEdit ? null : _onCategorySelected(category),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(Category category) {
    return isEdit
        ? Positioned(
          child: GestureDetector(
            onTap: () => _showDialogConfirmDelete(category),
            child: Icon(Icons.cancel, color: AppColors.negativeRed),
          ),
        )
        : Container();
  }
}
