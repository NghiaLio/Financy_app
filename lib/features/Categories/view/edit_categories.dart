// ignore_for_file: deprecated_member_use, use_build_context_synchronously, library_private_types_in_public_api

import 'package:financy_ui/core/constants/colors.dart';
import 'package:financy_ui/features/Categories/cubit/CategoriesCubit.dart';
import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:financy_ui/shared/utils/color_utils.dart';
import 'package:financy_ui/shared/utils/mappingIcon.dart';
import 'package:flutter/material.dart';
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

  final List<Color> _availableColors = AppColors.listIconColors;

  @override
  void initState() {
    super.initState();
    // _initializeForm();

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
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = category != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Category' : 'Add Category',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => _saveCategory(isEditing),
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.blue,
                fontSize: 16,
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
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
                  Theme.of(context).colorScheme.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(_selectedIcon, color: _selectedColor, size: 40),
          ),
          SizedBox(height: 12),
          Text(
            _nameController.text.isEmpty
                ? 'Category Name'
                : _nameController.text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color:
                  _nameController.text.isEmpty
                      ? Colors.grey[400]
                      : Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color:
                  _selectedType == 'income'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _selectedType?.toUpperCase() ?? '',
              style: TextStyle(
                color: _selectedType == 'income' ? Colors.green : Colors.red,
                fontSize: 12,
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
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        hintText: 'Enter category name',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a category name';
        }
        return null;
      },
      onChanged: (value) => setState(() {}), // Cập nhật preview
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
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
                          ? Colors.green
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
                              ? Colors.white
                              : Colors.grey[600],
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Income',
                      style: TextStyle(
                        color:
                            _selectedType == 'income'
                                ? Colors.white
                                : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 1, height: 20, color: Colors.grey[300]),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = 'expense'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color:
                      _selectedType == 'expense'
                          ? Colors.red
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
                              ? Colors.white
                              : Colors.grey[600],
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Expense',
                      style: TextStyle(
                        color:
                            _selectedType == 'expense'
                                ? Colors.white
                                : Colors.grey[600],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ExpansionTile(
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _selectedColor?.withOpacity(0.1) ?? Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_selectedIcon, color: _selectedColor, size: 20),
            ),
            SizedBox(width: 12),
            Text('Select Icon'),
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        fontSize: 14,
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
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.2)
                                          : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      isSelected
                                          ? Border.all(
                                            color:
                                                _selectedColor ??
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            width: 2,
                                          )
                                          : Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                ),
                                child: Icon(
                                  icon,
                                  color:
                                      isSelected
                                          ? _selectedColor
                                          : Colors.grey[600],
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
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
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
                            ? Border.all(color: Colors.grey[800]!, width: 3)
                            : Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child:
                      isSelected
                          ? Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _showDeleteConfirmDialog,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Delete Category',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
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
        await context.read<Categoriescubit>().updateCategory(index, category!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category not found'),
            backgroundColor: Colors.red,
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete "${category!.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
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
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Delete', style: TextStyle(color: Colors.white)),
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
