// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResultDialogAnimation extends StatelessWidget {
  final bool isSuccess;
  const ResultDialogAnimation({super.key, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            isSuccess
                ? 'assets/animation/Check Mark.json'
                : 'assets/animation/Tomato Error.json', // Replace with your Lottie animation file
            width: 150,
            height: 150,
            repeat: true,
          ),
          const SizedBox(height: 20),
          Text(
            isSuccess ? AppLocalizations.of(context)?.success ?? 'Success!' : AppLocalizations.of(context)?.error ?? 'Error!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
