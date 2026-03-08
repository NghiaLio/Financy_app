// ignore_for_file: file_names

import 'package:financy_ui/features/Account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/features/transactions/view/add.dart';
import 'package:financy_ui/features/Users/Cubit/userCubit.dart';
import 'package:financy_ui/features/transactions/view/home.dart';
import 'package:financy_ui/features/notification/cubit/notificationCubit.dart';
import 'package:financy_ui/features/Setting/settings.dart';
import 'package:financy_ui/features/transactions/view/statiscal.dart';
import 'package:financy_ui/features/transactions/view/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/l10n/app_localizations.dart';
import 'package:financy_ui/features/auth/cubits/authCubit.dart';
import 'package:financy_ui/features/auth/cubits/authState.dart';
import 'package:financy_ui/app/services/Local/settings_service.dart';
import 'package:financy_ui/features/Sync/services/background_sync_service.dart';
import 'package:financy_ui/core/utils/logger.dart';

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
    AddTransactionScreen(),
    Statiscal(),
    Settings(),
  ];

  @override
  void initState() {
    context.read<UserCubit>().getUser();
    context.read<ManageMoneyCubit>().getAllAccount();
    context.read<NotificationCubit>().loadNotificationSettings();

    // Start background sync if user is logged in with Google
    if (!SettingsService.isGuestLogin()) {
      debugLog('Starting background sync on app start');
      BackgroundSyncService.startBackgroundSync()
          .then((_) {
            debugLog('Background sync initiated');
          })
          .catchError((e) {
            debugLog('Failed to start background sync: $e');
          });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context);
    return BlocListener<Authcubit, Authstate>(
      listener: (context, state) {
        if (state.authStatus == AuthStatus.error ||
            state.authStatus == AuthStatus.unAuthenticated) {
          Navigator.pushNamed(context, '/login');
        }
      },
      child: Scaffold(
        body: SafeArea(child: _pages[_currentIndex]),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor:
              theme.bottomNavigationBarTheme.unselectedItemColor,
          currentIndex: _currentIndex,
          onTap: _toggleBottomNavigationBar,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              label: appLocal?.transactionBook ?? 'Transaction Book',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet),
              label: appLocal?.wallet ?? 'Wallet',
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
              label: appLocal?.statistics ?? 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: appLocal?.settings ?? 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
