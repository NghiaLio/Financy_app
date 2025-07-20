// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:financy_ui/features/settings/manage_account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/features/settings/manage_account/cubit/manageMoneyState.dart';
import 'package:financy_ui/features/settings/manage_account/models/money_source.dart';
import 'package:financy_ui/shared/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/colors.dart';
// import '../../../../core/constants/money_source_icons.dart';

class AddMoneySourceScreen extends StatefulWidget {
  const AddMoneySourceScreen({super.key});

  @override
  State<AddMoneySourceScreen> createState() => _AddMoneySourceScreenState();
}

class _AddMoneySourceScreenState extends State<AddMoneySourceScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedType = 'cash';
  String selectedCurrency = 'vnd';
  Color selectedColor = AppColors.primaryBlue;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.addMoneySource,
          style: textTheme.titleLarge!.copyWith(color: Colors.white),
        ),
      ),
      body: BlocListener<ManageMoneyCubit, ManageMoneyState>(
        listener: (context, state) {
          if (state.status == ManageMoneyStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.languageChanged),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.pop(context);
            });
          } else if (state.status == ManageMoneyStatus.error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                ),
                const SizedBox(height: 20),
                // Dropdown chọn loại nguồn tiền
                Text(
                  localizations.typeLabel,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.white,
                    cardColor: Colors.white,
                    popupMenuTheme: PopupMenuThemeData(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppColors.primaryBlue.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedType,
                    items: [
                      DropdownMenuItem(
                        value: 'cash',
                        child: Text(
                          localizations.typeCash,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'ewallet',
                        child: Text(
                          localizations.typeEwallet,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'banking',
                        child: Text(
                          localizations.typeBanking,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text(
                          localizations.typeOther,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryBlue.withOpacity(0.2),
                          width: 1.5,
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
                    style: textTheme.bodyLarge,
                    dropdownColor: Colors.white,
                    menuMaxHeight: 350,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 20),
                // Dropdown chọn loại tiền tệ
                Text(
                  localizations.currencyLabel,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.white,
                    cardColor: Colors.white,
                    popupMenuTheme: PopupMenuThemeData(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppColors.primaryBlue.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedCurrency,
                    items: [
                      DropdownMenuItem(
                        value: 'vnd',
                        child: Text(
                          localizations.currencyVnd,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'usd',
                        child: Text(
                          localizations.currencyUsd,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCurrency = value!;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryBlue.withOpacity(0.2),
                          width: 1.5,
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
                    style: textTheme.bodyLarge,
                    dropdownColor: Colors.white,
                    menuMaxHeight: 350,
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                ),
                const SizedBox(height: 20),
                // Chọn màu sắc
                Row(
                  children: [
                    Text(localizations.colorLabel),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showColorPicker(),
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
                      onPressed: addMoneySource,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        localizations.add,
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

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  TypeMoney _typeFromString(String value) {
    switch (value) {
      case 'cash':
        return TypeMoney.cash;
      case 'ewallet':
        return TypeMoney.eWallet;
      case 'banking':
        return TypeMoney.bank;
      case 'other':
        return TypeMoney.other;
      default:
        return TypeMoney.cash;
    }
  }

  CurrencyType _currencyFromString(String value) {
    switch (value) {
      case 'vnd':
        return CurrencyType.vnd;
      case 'usd':
        return CurrencyType.usd;
      default:
        return CurrencyType.vnd;
    }
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

  void addMoneySource() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng nhập tên nguồn tiền!')));
      return;
    }
    if (balanceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng nhập số dư!')));
      return;
    }
    final source = MoneySource(
      name: nameController.text,
      balance: double.tryParse(balanceController.text) ?? 0.0,
      type: _typeFromString(selectedType),
      currency: _currencyFromString(selectedCurrency),
      color: ColorUtils.colorToHex(selectedColor),
      description: descriptionController.text.isEmpty ? null : descriptionController.text,
    );
    context.read<ManageMoneyCubit>().createAccount(source);
  }

  // Đã loại bỏ chọn icon và màu thủ công, icon/màu tự động theo loại nguồn tiền
}
