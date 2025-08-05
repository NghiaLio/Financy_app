// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:developer';

import 'package:financy_ui/features/Account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/features/Account/models/money_source.dart';
import 'package:financy_ui/features/Users/Cubit/userCubit.dart';
import 'package:financy_ui/features/transactions/Cubit/transactionCubit.dart';
import 'package:financy_ui/features/transactions/Cubit/transctionState.dart';
import 'package:financy_ui/features/transactions/models/transactionsModels.dart';
import 'package:financy_ui/shared/utils/generateID.dart';
import 'package:financy_ui/shared/widgets/resultDialogAnimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:financy_ui/core/constants/colors.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  int selectedTransactionType = 0;
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  String selectedCategory = 'Select Category';
  String selectedDate = 'Today';
  String selectedAccount = 'Select Account';

  // For editing mode
  Transactionsmodels? editingTransaction;
  MoneySource? oldAccount;
  bool isEditing = false;

  final List<String> categories = [
    'Salary',
    'Business',
    'Investment',
    'Bonus',
    'Freelance',
    'Gift',
    'Other Income',
  ];

  late List<MoneySource> listAccounts;

  // Helper function for localization
  String _localText(String Function(AppLocalizations) getter) {
    final appLocal = AppLocalizations.of(context);
    return appLocal != null ? getter(appLocal) : '';
  }

  void _populateFieldsForEditing() {
    if (editingTransaction != null) {
      setState(() {
        // Set transaction type
        selectedTransactionType =
            editingTransaction!.type == TransactionType.income ? 0 : 1;

        // Set amount
        amountController.text = editingTransaction!.amount.toString();

        // Set category
        selectedCategory = editingTransaction!.categoriesId;

        // Set date
        if (editingTransaction!.transactionDate != null) {
          final date = editingTransaction!.transactionDate!;
          selectedDate = "${date.day}/${date.month}/${date.year}";
        }

        // Set account
        final account = listAccounts.firstWhere(
          (acc) => acc.id == editingTransaction!.accountId,
          orElse: () => listAccounts.first,
        );
        selectedAccount = account.name;

        // Set note
        noteController.text = editingTransaction!.note ?? '';
      });
    }
  }

  @override
  void initState() {
    listAccounts = context.read<ManageMoneyCubit>().listAccounts ?? [];

    // Check if we're in editing mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Transactionsmodels) {
        editingTransaction = args;
        oldAccount = listAccounts.firstWhere(
          (e) => e.id == editingTransaction?.accountId,
          orElse: () => listAccounts.first,
        );
        isEditing = true;
        _populateFieldsForEditing();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading:
            isEditing
                ? IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios, color: theme.highlightColor),
                )
                : null,
        title: Text(
          isEditing ? 'Edit Transaction' : _localText((l) => l.add),
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: BlocListener<Transactioncubit, TransactionState>(
        listener: (listenerContext, state) async {
          if (state.status == TransactionStateStatus.success) {
            _showResultEvent(listenerContext, true, context);
            amountController.clear();
            noteController.clear();
          }
          if (state.status == TransactionStateStatus.error) {
            _showResultEvent(listenerContext, false, context);
          }
        },
        child: Column(
          children: [
            // Transaction Type Tabs
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _buildTabButton(_localText((l) => l.income), 0),
                  SizedBox(width: 8),
                  _buildTabButton(_localText((l) => l.expense), 1),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount Field
                      _buildInputField(
                        label: _localText((l) => l.transactionAmount),
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            border: InputBorder.none,
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textGrey,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Category Field
                      _buildSelectField(
                        label: _localText((l) => l.category),
                        value: selectedCategory,
                        onTap: () => _showCategoryBottomSheet(),
                      ),

                      SizedBox(height: 20),

                      // Date Field
                      _buildSelectField(
                        label: _localText((l) => l.dueDate),
                        value: selectedDate,
                        onTap: () => _selectDate(),
                      ),

                      SizedBox(height: 20),

                      // Account Field
                      _buildSelectField(
                        label: _localText((l) => l.account),
                        value:
                            listAccounts.isEmpty
                                ? 'No accounts available'
                                : selectedAccount,
                        onTap:
                            listAccounts.isEmpty
                                ? null
                                : () => _showAccountBottomSheet(),
                      ),

                      SizedBox(height: 20),

                      // Note Field
                      _buildInputField(
                        label: _localText((l) => l.note),
                        child: TextField(
                          controller: noteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Add a note (optional)',
                            border: InputBorder.none,
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textGrey,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Confirm Button
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: listAccounts.isEmpty ? null : addTrans,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditing ? 'Update' : _localText((l) => l.save),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = index == selectedTransactionType;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTransactionType = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.positiveGreen
                    : AppColors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected ? AppColors.textDark : AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required Widget child}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textGrey,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey.withOpacity(0.3)),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildSelectField({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textGrey,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Opacity(
            opacity: onTap == null ? 0.5 : 1.0,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grey.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          value.contains('Select')
                              ? AppColors.textGrey
                              : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCategoryBottomSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),

              Text(
                _localText((l) => l.category),
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(height: 20),

              ...categories.map(
                (category) => ListTile(
                  title: Text(category, style: theme.textTheme.bodyMedium),
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAccountBottomSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),

              Text(
                _localText((l) => l.account),
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(height: 20),

              if (listAccounts.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 48,
                        color: AppColors.textGrey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No accounts available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please add a money source first',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...listAccounts.map(
                  (account) => ListTile(
                    title: Text(
                      account.name,
                      style: theme.textTheme.bodyMedium,
                    ),
                    onTap: () {
                      setState(() {
                        selectedAccount = account.name;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  bool _validate(double amount, MoneySource account) {
    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Amount must be greater than 0')));
      return false;
    }

    if (selectedTransactionType == 1 && amount > account.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient balance in account')),
      );
      return false;
    }

    if (selectedCategory == 'Select Category') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a category')));
      return false;
    }

    if (selectedAccount == 'Select Account') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select an account')));
      return false;
    }

    return true;
  }

  void addTrans() async {
    // Parse amount
    if (amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter an amount')));
      return;
    }

    final amount = double.parse(amountController.text.trim());

    // Parse date
    DateTime date;
    if (selectedDate == 'Today') {
      date = DateTime.now();
    } else {
      try {
        final parts = selectedDate.split('/');
        date = DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      } catch (e) {
        date = DateTime.now();
      }
    }

    // Get selected account
    final account = listAccounts.firstWhere(
      (e) => e.name == selectedAccount,
      orElse: () => listAccounts.first,
    );
    log(oldAccount?.name ?? '');

    final type =
        selectedTransactionType == 0
            ? TransactionType.income
            : TransactionType.expense;
    final uid = context.read<UserCubit>().state.user?.uid ?? '';

    // Validate input
    if (!_validate(amount, account)) {
      return;
    }
    double newAmonut;
    if (selectedTransactionType == 0) {
      newAmonut = account.balance + amount;
    } else {
      newAmonut = account.balance - amount;
    }

    if (isEditing && editingTransaction != null) {
      // Update existing transaction
      final updatedTransaction = Transactionsmodels(
        id: editingTransaction?.id ?? '',
        uid: editingTransaction?.uid ?? '',
        accountId: account.id ?? '',
        categoriesId: selectedCategory,
        type: type,
        amount: amount,
        note: noteController.text.trim(),
        transactionDate: date,
        createdAt: editingTransaction!.createdAt,
        isSync: false,
      );

      await context.read<Transactioncubit>().updateTransaction(
        updatedTransaction,
      );
    } else {
      // Create new transaction
      final transaction = Transactionsmodels(
        id: GenerateID.newID(),
        uid: uid,
        accountId: account.id ?? '',
        categoriesId: selectedCategory,
        type: type,
        amount: amount,
        note: noteController.text.trim(),
        transactionDate: date,
        createdAt: DateTime.now(),
        isSync: false,
      );

      await context.read<Transactioncubit>().addTransaction(transaction);
    }

    // --- Update account logic ---
    if (isEditing && editingTransaction != null) {
      // Nếu đổi tài khoản
      if (oldAccount?.id != account.id) {
        // Hoàn số tiền cũ về tài khoản cũ
        double oldAccBalance = oldAccount?.balance ?? 0;
        if (editingTransaction!.type == TransactionType.income) {
          oldAccBalance -= editingTransaction!.amount;
        } else {
          oldAccBalance += editingTransaction!.amount;
        }
        final newOldAccount = MoneySource(
          id: oldAccount?.id,
          name: oldAccount?.name ?? '',
          balance: oldAccBalance,
          type: oldAccount?.type,
          currency: oldAccount?.currency,
          iconCode: oldAccount?.iconCode,
          color: oldAccount?.color,
          description: oldAccount?.description,
          isActive: oldAccount?.isActive ?? false,
        );

        // Áp dụng thay đổi cho tài khoản mới
        double newAccBalance = account.balance;
        if (selectedTransactionType == 0) {
          newAccBalance += amount;
        } else {
          newAccBalance -= amount;
        }
        final newMoney = MoneySource(
          id: account.id,
          name: account.name,
          balance: newAccBalance,
          type: account.type,
          currency: account.currency,
          iconCode: account.iconCode,
          color: account.color,
          description: account.description,
          isActive: account.isActive,
        );

        await Future.wait([
          context.read<ManageMoneyCubit>().updateAccount(newMoney),
          context.read<ManageMoneyCubit>().updateAccount(newOldAccount),
        ]);
      } else {
        // Cùng tài khoản, kiểm tra thay đổi số tiền hoặc loại giao dịch
        double accBalance = account.balance;
        double oldAmount = editingTransaction!.amount;
        TransactionType oldType = editingTransaction!.type;

        // Hoàn lại số dư cũ
        if (oldType == TransactionType.income) {
          accBalance -= oldAmount;
        } else {
          accBalance += oldAmount;
        }
        // Áp dụng số dư mới
        if (selectedTransactionType == 0) {
          accBalance += amount;
        } else {
          accBalance -= amount;
        }
        final newMoney = MoneySource(
          id: account.id,
          name: account.name,
          balance: accBalance,
          type: account.type,
          currency: account.currency,
          iconCode: account.iconCode,
          color: account.color,
          description: account.description,
          isActive: account.isActive,
        );
        await context.read<ManageMoneyCubit>().updateAccount(newMoney);
      }
    } else {
      // Thêm mới transaction
      final newMoney = MoneySource(
        id: account.id,
        name: account.name,
        balance: newAmonut,
        type: account.type,
        currency: account.currency,
        iconCode: account.iconCode,
        color: account.color,
        description: account.description,
        isActive: account.isActive,
      );
      await context.read<ManageMoneyCubit>().updateAccount(newMoney);
    }
  }

  void _showResultEvent(
    BuildContext listenerContext,
    bool isSuccess,
    BuildContext rootContext,
  ) async {
    // Show result dialog
    showDialog(
      context: listenerContext,
      barrierDismissible: false,
      builder: (context) => ResultDialogAnimation(isSuccess: isSuccess),
    );

    // Wait 2 seconds, then close dialog and navigate
    await Future.delayed(const Duration(milliseconds: 1200));

    // Close dialog if still open
    if (Navigator.of(listenerContext).canPop()) {
      Navigator.of(listenerContext).pop();
    }
    // Navigate back to manage account
    if (mounted) {
      Navigator.of(
        rootContext,
      ).pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
    }
  }
}
