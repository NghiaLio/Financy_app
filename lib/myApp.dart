
// ignore_for_file: file_names

import 'package:financy_ui/add.dart';
import 'package:financy_ui/features/auth/cubits/authCubit.dart';
import 'package:financy_ui/home.dart';
import 'package:financy_ui/settings.dart';
import 'package:financy_ui/statiscal.dart';
import 'package:financy_ui/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  int _currentIndex = 0;
  void _toggleBottomNavigationBar(index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _pages = [
    Home(),
    Wallet(),
    Add(),
    Statiscal(),
    Settings(),
  ];

  @override
  void initState() {
    context.read<Authcubit>().getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        currentIndex: _currentIndex,
        onTap: _toggleBottomNavigationBar,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: appLocal?.transactionBook ?? 'Sổ giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: appLocal?.wallet ?? 'Ví tiền',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.bottomNavigationBarTheme.selectedItemColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: theme.bottomNavigationBarTheme.backgroundColor,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: appLocal?.statistics ?? 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: appLocal?.settings ?? 'Cài đặt',
          ),
        ],
      ),
    );
  }
}
