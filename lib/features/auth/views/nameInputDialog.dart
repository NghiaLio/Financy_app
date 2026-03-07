// ignore_for_file: file_names, use_build_context_synchronously

import 'package:financy_ui/features/auth/cubits/authCubit.dart';
import 'package:financy_ui/features/auth/cubits/authState.dart';
import 'package:financy_ui/shared/widgets/resultDialogAnimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/l10n/app_localizations.dart';

class InputDialog extends StatefulWidget {
  const InputDialog({super.key});

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  void _handleContinueAsGuest() async {
    // Simply login as guest without creating user
    await context.read<Authcubit>().loginWithNoAccount();
  }

  /// Handles authentication result by showing appropriate dialog and navigation
  Future<void> _handleAuthResult(BuildContext context, bool isSuccess) async {
    // Store the context before closing the dialog
    final navigatorContext = Navigator.of(context).context;

    // Close the current dialog first
    Navigator.of(context).pop();

    // Show result dialog
    showDialog(
      context: navigatorContext,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return ResultDialogAnimation(isSuccess: isSuccess);
      },
    );

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 1500));

    // Close result dialog
    if (navigatorContext.mounted) {
      Navigator.of(navigatorContext).pop();

      // Navigate based on result
      if (isSuccess) {
        // Navigate to home on success
        Navigator.pushNamedAndRemoveUntil(
          navigatorContext,
          '/',
          (route) => false,
        );
      } else {
        // Navigate back to login on error
        Navigator.pushNamedAndRemoveUntil(
          navigatorContext,
          '/login',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context);
    final textTheme = theme.textTheme;
    final primaryColor = theme.colorScheme.primary;

    return BlocListener<Authcubit, Authstate>(
      listener: (context, state) async {
        if (state.authStatus == AuthStatus.authenticated ||
            state.authStatus == AuthStatus.error) {
          await _handleAuthResult(
            context,
            state.authStatus == AuthStatus.authenticated,
          );
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Icon(Icons.person_outline, size: 64, color: primaryColor),
            const SizedBox(height: 16),

            // Dialog Title
            Text(
              'Continue as Guest',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'You can use the app without signing in. Sign in later to sync your data across devices.',
              style: textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.dividerColor),
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

                // Continue Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleContinueAsGuest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      appLocal?.continues ?? 'Continue',
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
