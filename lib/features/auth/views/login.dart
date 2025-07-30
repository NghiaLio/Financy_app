// ignore_for_file: use_build_context_synchronously

import 'package:financy_ui/features/auth/cubits/authCubit.dart';
import 'package:financy_ui/features/auth/views/nameInputDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? savedName;
  int? savedDay;
  int? savedMonth;
  int? savedYear;

  void loginGoogle() async {
    await context.read<Authcubit>().login();
    Hive.box('settings').put('app_state', true);
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _showInputDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => InputDialog(),
    );
  }

  void loginNoAccount() async {
    await _showInputDialog();
    Hive.box('settings').put('app_state', false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/image/image 1.png',
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.4,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              appLocal?.hello ?? 'Hello',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 44,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                appLocal?.loginToAccess ?? 'Login to access',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.06,
              child: OutlinedButton(
                onPressed: loginGoogle,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.secondary,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/image/google.png',
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      appLocal?.continue_with_google ?? 'Continue with Google',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              appLocal?.or ?? 'Or',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.06,
              child: OutlinedButton(
                onPressed: loginNoAccount,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.secondary,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      appLocal?.continue_without_account ?? 'Continue without account',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Text(
                appLocal?.agree_terms ?? 'I agree to the terms and conditions',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
