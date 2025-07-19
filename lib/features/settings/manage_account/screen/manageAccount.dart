// ignore_for_file: deprecated_member_use, file_names

import 'dart:developer';

import 'package:financy_ui/features/settings/manage_account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/features/settings/manage_account/cubit/manageMoneyState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/colors.dart';
import '../models/money_source.dart';

class AccountMoneyScreen extends StatefulWidget {
  const AccountMoneyScreen({super.key});

  @override
  State<AccountMoneyScreen> createState() => _AccountMoneyScreenState();
}

class _AccountMoneyScreenState extends State<AccountMoneyScreen> {
  bool isBalanceVisible = true;

  List<MoneySource> get moneySources => [];

  double get totalBalance =>
      moneySources.fold(0.0, (sum, source) => sum + source.balance);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (create) => ManageMoneyCubit()..getAllAccount(),
      child: BlocBuilder<ManageMoneyCubit, ManageMoneyState>(
        builder: (context, state) {
          log(state.status.toString());
          if (state.status == ManageMoneyStatus.loading) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (state.status == ManageMoneyStatus.error) {
            return Scaffold(body: Center(child: Text(state.message!)));
          } else {
            return Scaffold(
              backgroundColor: colorScheme.background,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  localizations.moneySources,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed:
                        () => Navigator.pushNamed(context, '/addMoneySource'),
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Total Balance Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryBlue, AppColors.accentPink],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizations.totalMoney,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isBalanceVisible = !isBalanceVisible;
                                });
                              },
                              icon: Icon(
                                isBalanceVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isBalanceVisible
                              ? '\$${totalBalance.toStringAsFixed(2)}'
                              : '••••••',
                          style: textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.sourcesAvailable(moneySources.length),
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Money Sources List
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              localizations.moneySources,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: moneySources.length,
                              itemBuilder: (context, index) {
                                final source = moneySources[index];
                                return _MoneySourceTile(
                                  source: source,
                                  isBalanceVisible: isBalanceVisible,
                                  onTap: () => _showSourceDetailDialog(source),
                                  onEdit:
                                      () =>
                                          _showEditSourceDialog(source, index),
                                  onDelete: () => _deleteSource(index),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }


  void _showSourceDetailDialog(MoneySource source) {
    final TextEditingController amountController = TextEditingController();
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(source.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: source.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(source.icon, color: source.color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ' ${source.balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: localizations.addRemoveMoney,
                    prefixText: ' ',
                    border: const OutlineInputBorder(),
                    hintText: localizations.useMinusForRemove,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null) {
                    setState(() {
                      final index = moneySources.indexWhere(
                        (s) => s.id == source.id,
                      );
                      if (index != -1) {
                        moneySources[index].balance += amount;
                      }
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: source.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  localizations.update,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditSourceDialog(MoneySource source, int index) {
    final TextEditingController nameController = TextEditingController(
      text: source.name,
    );

    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(localizations.editSource),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: localizations.sourceName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    moneySources[index].name = nameController.text;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  localizations.save,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _deleteSource(int index) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.deleteSource),
            content: Text(
              localizations.deleteSourceConfirm(moneySources[index].name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    moneySources.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.negativeRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  localizations.delete,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }


}

class _MoneySourceTile extends StatelessWidget {
  final MoneySource source;
  final bool isBalanceVisible;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MoneySourceTile({
    required this.source,
    required this.isBalanceVisible,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: source.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(source.icon, color: source.color, size: 24),
        ),
        title: Text(
          source.name,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              isBalanceVisible
                  ? ' ${source.balance.toStringAsFixed(2)}'
                  : '      ',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.positiveGreen,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(localizations.edit, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: colorScheme.error),
                      const SizedBox(width: 8),
                      Text(
                        localizations.delete,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
        ),
        onTap: onTap,
      ),
    );
  }
}
