// ignore_for_file: file_names, use_build_context_synchronously

import 'package:financy_ui/features/Users/models/userModels.dart';
import 'package:financy_ui/features/auth/cubits/authCubit.dart';
import 'package:financy_ui/features/auth/cubits/authState.dart';
import 'package:financy_ui/shared/utils/generateID.dart';
import 'package:financy_ui/shared/widgets/successAnimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InputDialog extends StatefulWidget {
  const InputDialog({super.key});

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  late TextEditingController nameController;
  late TextEditingController dayController;
  late TextEditingController monthController;
  late TextEditingController yearController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    dayController = TextEditingController();
    monthController = TextEditingController();
    yearController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    super.dispose();
  }

  bool _isValidDate(int day, int month, int year) {
    if (month < 1 || month > 12) return false;
    if (day < 1) return false;
    if (year < 1900 || year > DateTime.now().year) return false;

    List<int> daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && _isLeapYear(year)) {
      daysInMonth[1] = 29;
    }
    return day <= daysInMonth[month - 1];
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  void _handleSave() async {
    final appLocal = AppLocalizations.of(context);
    if (nameController.text.trim().isEmpty) {
      _showError(appLocal?.pleaseEnterName ?? 'Please enter a name');
      return;
    }
    final day = int.tryParse(dayController.text);
    final month = int.tryParse(monthController.text);
    final year = int.tryParse(yearController.text);

    if (day == null || month == null || year == null) {
      _showError(
        appLocal?.pleaseEnterValidNumbers ??
            'Please enter valid numbers for day, month, and year',
      );
      return;
    }
    if (!_isValidDate(day, month, year)) {
      _showError(appLocal?.pleaseEnterValidDate ?? 'Please enter a valid date');
      return;
    }

    final newUser = UserModel(
      id: GenerateID.newID(),
      name: nameController.text.trim(),
      picture: '',
      createdAt: DateTime.now(),
      uid: '',
      email: '',
      dateOfBirth: DateTime(year, month, day),
    );
    await context.read<Authcubit>().loginWithNoAccount(newUser);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context);
    final textTheme = theme.textTheme;
    final borderColor = theme.dividerColor;
    final primaryColor = theme.colorScheme.primary;
    final labelColor = textTheme.bodyMedium?.color ?? Colors.black;

    return BlocListener<Authcubit, Authstate>(
      listener: (context, state) async {
        if (state.authStatus == AuthStatus.authenticated) {
          // Lưu context của dialog
          BuildContext? dialogContext;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext ctx) {
              dialogContext = ctx;
              return const SuccessAlertDialog();
            },
          );
          await Future.delayed(const Duration(milliseconds: 1000));
          if (dialogContext != null) {
            Navigator.of(
              dialogContext!,
            ).pop(); // Đóng dialog bằng context của dialog
          }
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog Title
            Text(
              appLocal?.personalInformation ?? 'Personal Information',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Name Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLocal?.fullName ?? 'Full Name',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: appLocal?.enterFullName ?? 'Enter your full name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: textTheme.bodyLarge,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Date of Birth Label
            Text(
              appLocal?.dateOfBirth ?? 'Date of Birth',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 8),

            // Date Inputs Row
            Row(
              children: [
                // Day Input
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLocal?.day ?? 'Day',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: dayController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: InputDecoration(
                          hintText: 'DD',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Month Input
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLocal?.month ?? 'Month',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: monthController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: InputDecoration(
                          hintText: 'MM',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Year Input
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLocal?.year ?? 'Year',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          hintText: 'YYYY',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      appLocal?.cancel ?? 'Cancel',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Save Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      appLocal?.save ?? 'Save',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
