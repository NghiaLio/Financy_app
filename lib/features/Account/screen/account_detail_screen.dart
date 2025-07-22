// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:financy_ui/features/Account/cubit/manageMoneyCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../Account/models/money_source.dart';
import '../../../core/constants/colors.dart';
import 'package:financy_ui/shared/utils/color_utils.dart';
import 'package:financy_ui/features/Account/cubit/manageMoneyState.dart';

class AccountDetailScreen extends StatefulWidget {
  final MoneySource account;
  const AccountDetailScreen({super.key, required this.account});

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
    nameController = TextEditingController(text: widget.account.name);
    balanceController = TextEditingController(
      text: widget.account.balance.toString(),
    );
    descriptionController = TextEditingController(
      text: widget.account.description ?? '',
    );
    selectedColor =
        ColorUtils.parseColor(widget.account.color!) ?? AppColors.primaryBlue;
    isActive = widget.account.isActive;
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
            title: Text(AppLocalizations.of(context)!.colorLabel),
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
        id: widget.account.id,
        name: nameController.text,
        balance: double.tryParse(balanceController.text) ?? 0.0,
        type: widget.account.type,
        currency: widget.account.currency,
        description: descriptionController.text,
        color: ColorUtils.colorToHex(selectedColor),
        isActive: isActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _rootContext = context;
    final localizations = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return BlocListener<ManageMoneyCubit, ManageMoneyState>(
      listener: (listenerContext, state) async {
        if (state.status == ManageMoneyStatus.error ||
            state.status == ManageMoneyStatus.success) {
          final isSuccess = state.status == ManageMoneyStatus.success;
          final message =
              isSuccess
                  ? localizations.update
                  : (state.message ?? 'Unknown error');
          final icon =
              isSuccess
                  ? Icon(Icons.check_circle, color: AppColors.positiveGreen, size: 48)
                  : Icon(Icons.cancel, color: AppColors.negativeRed, size: 48);
          await showDialog(
            context: listenerContext,
            barrierDismissible: false,
            builder: (context) {
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              });
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon,
                      const SizedBox(height: 16),
                      Text(
                        localizations.notification,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isSuccess
                                  ? AppColors.positiveGreen
                                  : AppColors.negativeRed,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          if (mounted) {
            Navigator.of(_rootContext).pushNamedAndRemoveUntil(
              '/manageAccount',
              ModalRoute.withName('/'),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            localizations.accountDetail,
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
                            ? localizations.active
                            : localizations.inactive,
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
                  localizations.sourceName,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.edit),
                    hintText: localizations.sourceName,
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
                  localizations.initialBalance,
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
                    hintText: localizations.initialBalance,
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
                  localizations.descriptionOptional,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.notes),
                    hintText: localizations.descriptionOptional,
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
                    Text(localizations.colorLabel),
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
                      child: Text(localizations.cancel),
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
                        localizations.save,
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
