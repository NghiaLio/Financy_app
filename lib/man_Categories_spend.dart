// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';

class ExpenseCategoriesScreen extends StatefulWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  State<ExpenseCategoriesScreen> createState() => _ExpenseCategoriesScreenState();
}

class _ExpenseCategoriesScreenState extends State<ExpenseCategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<CategoryItem> expenseCategories = [
    CategoryItem(
      icon: Icons.local_grocery_store,
      label: 'Food',
      color: Colors.green,
    ),
    CategoryItem(
      icon: Icons.restaurant,
      label: 'Dining',
      color: Colors.orange,
    ),
    CategoryItem(
      icon: Icons.local_shipping,
      label: 'Transport',
      color: Colors.blue,
    ),
    CategoryItem(
      icon: Icons.checkroom,
      label: 'Fashion',
      color: Colors.purple,
    ),
    CategoryItem(
      icon: Icons.local_bar,
      label: 'Drinks',
      color: Colors.red,
    ),
    CategoryItem(
      icon: Icons.pets,
      label: 'Pets',
      color: Colors.brown,
    ),
    CategoryItem(
      icon: Icons.school,
      label: 'Education',
      color: Colors.indigo,
    ),
    CategoryItem(
      icon: Icons.local_hospital,
      label: 'Health',
      color: Colors.teal,
    ),
    CategoryItem(
      icon: Icons.beach_access,
      label: 'Travel',
      color: Colors.cyan,
    ),
    CategoryItem(
      icon: Icons.sports_esports,
      label: 'Entertainment',
      color: Colors.pink,
    ),
    CategoryItem(
      icon: Icons.water_drop,
      label: 'Water Bill',
      color: Colors.lightBlue,
    ),
    CategoryItem(
      icon: Icons.electrical_services,
      label: 'Electricity Bill',
      color: Colors.amber,
    ),
    CategoryItem(
      icon: Icons.receipt_long,
      label: 'Bills',
      color: Colors.grey,
    ),
    CategoryItem(
      icon: Icons.card_giftcard,
      label: 'Gifts',
      color: Colors.pinkAccent,
    ),
  ];

  final List<CategoryItem> incomeCategories = [
    CategoryItem(
      icon: Icons.work,
      label: 'Salary',
      color: Colors.green,
    ),
    CategoryItem(
      icon: Icons.business,
      label: 'Business',
      color: Colors.blue,
    ),
    CategoryItem(
      icon: Icons.trending_up,
      label: 'Investment',
      color: Colors.orange,
    ),
    CategoryItem(
      icon: Icons.card_giftcard,
      label: 'Gifts',
      color: Colors.purple,
    ),
  ];

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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: Column(
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
      ),
    );
  }

  Widget _buildCategoryGrid(List<CategoryItem> categories) {
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

  Widget _buildCategoryItem(CategoryItem category) {
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
                color: category.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.label,
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
            Icon(
              Icons.add_circle,
              color: Colors.blue,
              size: 50,
            ),
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

  

  void _onCategorySelected(CategoryItem category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${category.label}'),
        backgroundColor: category.color,
        duration: const Duration(seconds: 1),
      ),
    );
    
    // Return selected category to parent screen
    Navigator.pop(context, category);
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A3E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Edit Categories', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showEditCategoriesDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.white),
              title: const Text('Restore Default', style: TextStyle(color: Colors.white)),
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
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Add New Category', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Category Name',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                // Add new category logic here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added category: ${nameController.text}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
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
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Restore Default', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Do you want to restore all categories to default?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
            child: const Text('Restore', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class CategoryItem {
  final IconData icon;
  final String label;
  final Color color;

  CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}