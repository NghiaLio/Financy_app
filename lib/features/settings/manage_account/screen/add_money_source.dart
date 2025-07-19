// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/money_source_icons.dart';

class AddMoneySourceScreen extends StatefulWidget {
  const AddMoneySourceScreen({super.key});

  @override
  State<AddMoneySourceScreen> createState() => _AddMoneySourceScreenState();
}

class _AddMoneySourceScreenState extends State<AddMoneySourceScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  IconData selectedIcon = Icons.account_balance_wallet;
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
      body: Padding(
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
              Center(
                child: OutlinedButton.icon(
                  icon: const Icon(
                    Icons.account_balance,
                    color: AppColors.primaryBlue,
                  ),
                  label: Text(
                    localizations.linkBank,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text(localizations.linkBankDialogTitle),
                            content: Text(localizations.linkBankDialogContent),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(localizations.close),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(localizations.iconLabel),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showIconPicker(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selectedColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: selectedColor),
                      ),
                      child: Icon(selectedIcon, color: selectedColor),
                    ),
                  ),
                  const SizedBox(width: 16),
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
                    onPressed: () {
                      if (nameController.text.isNotEmpty &&
                          balanceController.text.isNotEmpty) {
                        final balance =
                            double.tryParse(balanceController.text) ?? 0.0;
                        Navigator.pop(context, {
                          'name': nameController.text,
                          'balance': balance,
                          'icon': selectedIcon,
                          'color': selectedColor,
                          'description': descriptionController.text,
                        });
                      }
                    },
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
    );
  }

  void _showIconPicker() {
    final icons = MoneySourceIcons.all;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chọn biểu tượng'),
            content: Wrap(
              children:
                  icons
                      .map(
                        (icon) => GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIcon = icon;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Icon(icon),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
    );
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
            title: const Text('Chọn màu sắc'),
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
}
