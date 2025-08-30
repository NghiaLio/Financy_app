// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:financy_ui/features/Account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/features/Account/cubit/manageMoneyState.dart';
import 'package:financy_ui/features/Account/models/money_source.dart';
import 'package:financy_ui/shared/utils/color_utils.dart';
import 'package:financy_ui/shared/utils/generateID.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/money_source_icons.dart';

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
  String? selectedBrandKey;

  List<String> _brandKeysForType(String type) {
    if (type == 'ewallet') {
      return const ['shopeepay', 'viettelpay', 'vnpay', 'zalopay', 'momo'];
    }
    if (type == 'banking') {
      return const [
        'tpbank',
        'acb',
        'mbbank',
        'vpbank',
        'vietcombank',
        'vietinbank',
        'bidv',
        'techcombank',
        'agribank',
      ];
    }
    return const [];
  }

  String _brandDisplayName(String key) {
    const map = {
      'shopeepay': 'ShopeePay',
      'viettelpay': 'ViettelPay',
      'vnpay': 'VNPAY',
      'zalopay': 'ZaloPay',
      'momo': 'MoMo',
      'tpbank': 'TPBank',
      'acb': 'ACB',
      'mbbank': 'MBBank',
      'vpbank': 'VPBank',
      'vietcombank': 'Vietcombank',
      'vietinbank': 'VietinBank',
      'bidv': 'BIDV',
      'techcombank': 'Techcombank',
      'agribank': 'Agribank',
    };
    return map[key] ?? key;
  }

  Widget _buildBrandGrid(
    BuildContext context,
    Color backgroundColor,
    Color borderColor,
  ) {
    final keys = _brandKeysForType(selectedType);
    if (keys.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          keys.map((key) {
            final asset = MoneySourceImages.nameToAsset[key];
            if (asset == null) return const SizedBox.shrink();
            final isSelected = selectedBrandKey == key;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedBrandKey = key;
                  nameController.text = _brandDisplayName(key);
                  selectedColor = MoneySourceColors.colorForWithFallback(
                    key,
                    fallback: AppColors.primaryBlue,
                  );
                });
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor,
                  border: Border.all(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: ClipOval(
                  child: Image.asset(
                    asset,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AppLocalizations.of(context) will never be null in a properly configured app
    final localizations = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors
    final backgroundColor = isDark ? const Color(0xFF2A2A3E) : Colors.white;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final borderColor =
        isDark
            ? AppColors.textGrey.withOpacity(0.3)
            : AppColors.primaryBlue.withOpacity(0.2);
    final focusedBorderColor =
        isDark ? AppColors.primaryBlue : AppColors.primaryBlue;
    final hintColor =
        isDark ? AppColors.textGrey.withOpacity(0.7) : Colors.grey[600];

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
                content: Text(
                  AppLocalizations.of(context)?.success ?? 'Success',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.pop(context);
            });
          } else if (state.status == ManageMoneyStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'An error occurred')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown chọn loại nguồn tiền (moved to top)
                Text(
                  localizations.typeLabel,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: backgroundColor,
                    cardColor: backgroundColor,
                    popupMenuTheme: PopupMenuThemeData(
                      color: backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: borderColor, width: 1.5),
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
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'ewallet',
                        child: Text(
                          localizations.typeEwallet,
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'banking',
                        child: Text(
                          localizations.typeBanking,
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text(
                          localizations.typeOther,
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                        selectedBrandKey = null;
                        nameController.text = '';
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: backgroundColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: focusedBorderColor,
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(color: textColor),
                    dropdownColor: backgroundColor,
                    menuMaxHeight: 350,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedType == 'ewallet' || selectedType == 'banking') ...[
                  _buildBrandGrid(context, backgroundColor, borderColor),
                  const SizedBox(height: 16),
                ],
                Text(
                  localizations.sourceName,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.edit,
                      color: textColor.withOpacity(0.7),
                    ),
                    hintText: localizations.sourceName,
                    hintStyle: TextStyle(color: hintColor),
                    filled: true,
                    fillColor: backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: focusedBorderColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Dropdown chọn loại tiền tệ
                Text(
                  localizations.currencyLabel,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: backgroundColor,
                    cardColor: backgroundColor,
                    popupMenuTheme: PopupMenuThemeData(
                      color: backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: borderColor, width: 1.5),
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
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'usd',
                        child: Text(
                          localizations.currencyUsd,
                          style: TextStyle(color: textColor),
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
                      fillColor: backgroundColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: focusedBorderColor,
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(color: textColor),
                    dropdownColor: backgroundColor,
                    menuMaxHeight: 350,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  localizations.initialBalance,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: textColor.withOpacity(0.7),
                    ),
                    hintText: localizations.initialBalance,
                    filled: true,
                    hintStyle: TextStyle(color: hintColor),
                    fillColor: backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: focusedBorderColor,
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
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.notes,
                      color: textColor.withOpacity(0.7),
                    ),
                    hintText: localizations.descriptionOptional,
                    hintStyle: TextStyle(color: hintColor),
                    filled: true,
                    fillColor: backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: focusedBorderColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Chỉ cho chọn màu nếu không phải ewallet hoặc banking
                if (selectedType != 'ewallet' && selectedType != 'banking') ...[
                  Row(
                    children: [
                      Text(
                        localizations.colorLabel,
                        style: TextStyle(color: textColor),
                      ),
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
                ],

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

  void addMoneySource() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter source name!')));
      return;
    }
    if (balanceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter balance!')));
      return;
    }
    final source = MoneySource(
      id: GenerateID.newID(),
      name: nameController.text,
      balance: double.tryParse(balanceController.text) ?? 0.0,
      type: _typeFromString(selectedType),
      currency: _currencyFromString(selectedCurrency),
      color: ColorUtils.colorToHex(selectedColor),
      description:
          descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
      isActive: true,
    );
    context.read<ManageMoneyCubit>().createAccount(source);
  }
}
