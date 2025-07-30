// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessAlertDialog extends StatelessWidget {
  const SuccessAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/animation/Check Mark.json', // Replace with your Lottie animation file
            width: 150,
            height: 150,
            repeat: true,
          ),
          const SizedBox(height: 20),
          Text(
            'Success!',
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
