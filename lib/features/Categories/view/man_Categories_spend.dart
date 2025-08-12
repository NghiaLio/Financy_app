// ignore_for_file: file_names, deprecated_member_use
import 'package:financy_ui/core/constants/icons.dart';
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
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
            onPressed: () {
              _showOptionsMenu(context, theme);
            },
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
                backgroundColor: theme.colorScheme.secondary,
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
                        ? _buildCategoryGrid(expenseCategories)
                        : _buildCategoryList(expenseCategories),
                    _isGridView
                        ? _buildCategoryGrid(incomeCategories)
                        : _buildCategoryList(incomeCategories),
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

  Widget _buildCategoryList(List<Category> categories) {
    // Add the "+" button at the end
    final categoriesWithAdd = [...categories];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: categoriesWithAdd.length + 1, // +1 for add button
        itemBuilder: (context, index) {
          if (index == categoriesWithAdd.length) {
            return _buildAddListItem();
          }
          return _buildCategoryListItem(categoriesWithAdd[index]);
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
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
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        _showAddCategoryDialog();
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle,
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.manageCategory ?? 'Manage categories',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
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
                    AppLocalizations.of(context)?.manageCategory ??
                        'Manage categories',
                    style: theme.textTheme.bodyLarge,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditCategoriesDialog();
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

  void _showAddCategoryDialog() {
    Navigator.pushNamed(context, '/editCategory');
  }

  void _showEditCategoriesDialog() {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)?.manageCategory ?? 'Manage categories',
          style: theme.textTheme.bodyMedium,
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
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

  Widget _buildCategoryListItem(Category category) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
                ColorUtils.parseColor(category.color)?.withOpacity(0.1) ??
                theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            IconMapping.stringToIcon(category.icon),
            color: ColorUtils.parseColor(category.color),
            size: 24,
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
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: theme.hintColor,
          size: 16,
        ),
        onTap: () => _onCategorySelected(category),
      ),
    );
  }

  Widget _buildAddListItem() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add, color: theme.primaryColor, size: 24),
        ),
        title: Text(
          l10n?.manageCategory ?? 'Manage categories',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.primaryColor,
          ),
        ),
        subtitle: Text(
          'Add new category',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: theme.primaryColor,
          size: 16,
        ),
        onTap: () => _showAddCategoryDialog(),
      ),
    );
  }
}
