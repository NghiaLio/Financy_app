// ignore_for_file: deprecated_member_use, use_build_context_synchronously, library_private_types_in_public_api, non_constant_identifier_names

import 'package:financy_ui/core/constants/colors.dart';
import 'package:financy_ui/features/Categories/cubit/CategoriesCubit.dart';
import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:financy_ui/shared/utils/color_utils.dart';
import 'package:financy_ui/shared/utils/mappingIcon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEditCategoryScreen extends StatefulWidget {
  const AddEditCategoryScreen({super.key});

  @override
  _AddEditCategoryScreenState createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  Category? category;
  TextEditingController _nameController = TextEditingController();

  String? _selectedType;
  IconData? _selectedIcon;
  Color? _selectedColor;
  bool _isLoading = false;

  // Available icons grouped by category
  final Map<String, List<IconData>> _iconCategories =
      IconMapping.groupIconsByCategory();

  late List<Color> _availableColors;

  @override
  void initState() {
    super.initState();
    // _initializeForm();
    _availableColors = List<Color>.from(AppColors.listIconColors);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Category) {
        category = args;
        _initializeForm();
      }
    });
  }

  void _initializeForm() {
    setState(() {
      _nameController = TextEditingController(text: category?.name ?? '');

      _selectedType = category?.type ?? 'income';
      _selectedIcon = IconMapping.stringToIcon(category?.icon ?? 'home');
      _selectedColor =
          ColorUtils.parseColor(category?.color ?? '#0000FF') ??
          _availableColors[0];
      // Ensure the category's color appears in the palette and is selectable
      if (_selectedColor != null && !_availableColors.contains(_selectedColor)) {
        _availableColors.insert(0, _selectedColor!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    bool isEditing = category != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n?.manageCategory ?? 'Manage categories',
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => _saveCategory(isEditing),
            child: Text(
              l10n?.save ?? 'Save',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _isLoading ? theme.disabledColor : theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Card
              _buildPreviewCard(),
              SizedBox(height: 30),

              // Category Name
              _buildSectionTitle('Category Name'),
              SizedBox(height: 12),
              _buildNameField(),
              SizedBox(height: 24),

              // Category Type
              _buildSectionTitle('Type'),
              SizedBox(height: 12),
              _buildTypeSelector(),
              SizedBox(height: 24),

              // Icon Selection
              _buildSectionTitle('Icon'),
              SizedBox(height: 12),
              _buildIconSelector(),
              SizedBox(height: 24),

              // Color Selection
              _buildSectionTitle('Color'),
              SizedBox(height: 12),
              _buildColorSelector(),
              SizedBox(height: 24),

              SizedBox(height: 12),
              // Delete Button (chỉ hiển thị khi edit)
              if (isEditing) _buildDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Preview',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color:
                  _selectedColor?.withOpacity(0.1) ??
                  theme.colorScheme.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(_selectedIcon, color: _selectedColor, size: 40),
          ),
          SizedBox(height: 12),
          Text(
            _nameController.text.isEmpty
                ? 'Category Name'
                : _nameController.text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  _nameController.text.isEmpty
                      ? theme.disabledColor
                      : theme.textTheme.titleMedium?.color,
            ),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color:
                  _selectedType == 'income'
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _selectedType == null ? '' : (_selectedType == 'income'
                      ? (AppLocalizations.of(context)?.income ?? 'Income')
                      : (AppLocalizations.of(context)?.expense ?? 'Expense'))
                  .toUpperCase(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _selectedType == 'income'
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildNameField() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        hintText: 'Enter category name',
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n?.pleaseEnterName ?? 'Please enter a name';
        }
        return null;
      },
      onChanged: (value) => setState(() {}), // Cập nhật preview
    );
  }

  Widget _buildTypeSelector() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = 'income'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color:
                      _selectedType == 'income'
                          ? theme.primaryColor
                          : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color:
                          _selectedType == 'income'
                              ? theme.colorScheme.onPrimary
                              : theme.hintColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)?.income ?? 'Income',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _selectedType == 'income'
                                ? theme.colorScheme.onPrimary
                                : theme.hintColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 1, height: 20, color: Theme.of(context).dividerColor),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = 'expense'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color:
                      _selectedType == 'expense'
                          ? theme.colorScheme.error
                          : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_down,
                      color:
                          _selectedType == 'expense'
                              ? theme.colorScheme.onError
                              : theme.hintColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)?.expense ?? 'Expense',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _selectedType == 'expense'
                                ? theme.colorScheme.onError
                                : theme.hintColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ExpansionTile(
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _selectedColor?.withOpacity(0.1) ?? theme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_selectedIcon, color: _selectedColor, size: 20),
            ),
            SizedBox(width: 12),
            Text(AppLocalizations.of(context)?.chooseIcon ?? 'Choose Icon'),
          ],
        ),
        children:
            _iconCategories.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      entry.key,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          entry.value.map((icon) {
                            bool isSelected = icon == _selectedIcon;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedIcon = icon),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? _selectedColor?.withOpacity(0.2) ??
                                              theme.colorScheme.primary.withOpacity(0.2)
                                          : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      isSelected
                                          ? Border.all(
                                            color:
                                                _selectedColor ?? theme.colorScheme.primary,
                                            width: 2,
                                          )
                                          : Border.all(
                                            color: theme.dividerColor,
                                          ),
                                ),
                                child: Icon(
                                  icon,
                                  color:
                                      isSelected ? _selectedColor : theme.hintColor,
                                  size: 20,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildColorSelector() {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children:
            _availableColors.map((color) {
              bool isSelected = color == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border:
                        isSelected
                            ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                            : Border.all(color: theme.dividerColor, width: 1),
                  ),
                  child:
                      isSelected
                          ? Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 20)
                          : null,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildDeleteButton() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _showDeleteConfirmDialog,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.error),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: theme.colorScheme.error),
            SizedBox(width: 8),
            Text(
              '${l10n?.delete ?? 'Delete'} ${l10n?.category ?? 'Category'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategory(bool isEdit) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    Category new_category = Category(
      id: category?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      icon: IconMapping.mapIconToString(_selectedIcon ?? Icons.category),
      color: ColorUtils.colorToHex(_selectedColor ?? Colors.grey),
      type: _selectedType ?? '',
      createdAt: category?.createdAt ?? DateTime.now(),
    );

    if (isEdit) {
      //find index
      int index = await context.read<Categoriescubit>().getIndexOfCategory(
        category!,
      );
      // updateCategory
      if (index != -1) {
        await context.read<Categoriescubit>().updateCategory(index, new_category);
      } else {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category not found', style: theme.textTheme.bodyMedium),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } else {
      await context.read<Categoriescubit>().addCategory(new_category);
    }

    setState(() => _isLoading = false);

    // Return result
    Navigator.pop(context, {
      'action': category != null ? 'edit' : 'add',
      'category': new_category,
    });
  }

  void _showDeleteConfirmDialog() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('${l10n?.delete ?? 'Delete'} ${l10n?.category ?? 'Category'}'),
          content: Text('Are you sure you want to delete "${category!.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, {
                  'action': 'delete',
                  'category': category,
                }); // Return to previous screen with delete action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n?.delete ?? 'Delete',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
