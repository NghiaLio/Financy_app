// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:financy_ui/features/Account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/shared/widgets/resultDialogAnimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../Account/models/money_source.dart';
import '../../../core/constants/colors.dart';
import 'package:financy_ui/shared/utils/color_utils.dart';
import 'package:financy_ui/features/Account/cubit/manageMoneyState.dart';

class AccountDetailScreen extends StatefulWidget {
  final MoneySource? account;
  const AccountDetailScreen({super.key, this.account});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  late BuildContext _rootContext;
  late TextEditingController nameController;
  late TextEditingController balanceController;
  late TextEditingController descriptionController;
  late Color selectedColor;
  late bool isActive;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.account?.name ?? '');
    balanceController = TextEditingController(
      text: widget.account?.balance.toString(),
    );
    descriptionController = TextEditingController(
      text: widget.account?.description ?? '',
    );
    selectedColor =
        ColorUtils.parseColor(widget.account?.color ?? '') ?? AppColors.primaryBlue;
    isActive = widget.account?.isActive ?? false;
  }

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    final colors = [
      AppColors.primaryBlue,
      AppColors.positiveGreen,
      AppColors.negativeRed,
      AppColors.accentPink,
      AppColors.purple,
      AppColors.orange,
      AppColors.green,
      AppColors.cyan,
    ];
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context)?.colorLabel ?? 'Choose Color',
            ),
            content: Wrap(
              children:
                  colors
                      .map(
                        (color) => GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  void _saveChanges() {
    context.read<ManageMoneyCubit>().updateAccount(
      MoneySource(
        id: widget.account?.id ?? '',
        name: nameController.text,
        balance: double.tryParse(balanceController.text) ?? 0.0,
        type: widget.account?.type ?? TypeMoney.cash,
        currency: widget.account?.currency ?? CurrencyType.vnd,
        description: descriptionController.text,
        color: ColorUtils.colorToHex(selectedColor),
        isActive: isActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _rootContext = context;
    // AppLocalizations.of(context) will never be null in a properly configured app
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return BlocListener<ManageMoneyCubit, ManageMoneyState>(
      listener: (listenerContext, state) async {
        if (state.status == ManageMoneyStatus.error ||
            state.status == ManageMoneyStatus.success) {
          final isSuccess = state.status == ManageMoneyStatus.success;

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
          
          // Navigate back to previous screen
          if (mounted) {
            Navigator.of(_rootContext).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            localizations?.accountDetail ?? 'Account Detail',
            style: textTheme.titleLarge!.copyWith(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isActive
                                ? AppColors.positiveGreen
                                : AppColors.negativeRed,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive
                            ? localizations?.active ?? 'Active'
                            : localizations?.inactive ?? 'Inactive',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: isActive,
                      activeColor: AppColors.positiveGreen,
                      inactiveThumbColor: AppColors.negativeRed,
                      onChanged: (value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  localizations?.sourceName ?? 'Source Name',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.edit),
                    hintText: localizations?.sourceName ?? 'Source Name',
                    hintStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Text(
                  localizations?.initialBalance ?? 'Initial Balance',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.attach_money),
                    hintText: localizations?.initialBalance ?? 'Initial Balance',
                    hintStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Text(
                  localizations?.descriptionOptional ?? 'Description (Optional)',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.notes),
                    hintText: localizations?.descriptionOptional ?? 'Description (Optional)',
                    hintStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(localizations?.colorLabel ?? 'Color'),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showColorPicker,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(localizations?.cancel ?? 'Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        localizations?.save ?? 'Save',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
