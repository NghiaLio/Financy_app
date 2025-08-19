// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:financy_ui/app/services/Local/notifications.dart';
import 'package:financy_ui/features/Users/Cubit/userCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  // Hàm tiện ích
  String _localText(
    BuildContext context,
    String Function(AppLocalizations) getter,
  ) {
    final appLocal = AppLocalizations.of(context);
    return appLocal != null ? getter(appLocal) : '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.translate,
            title: _localText(context, (l) => l.language),
            iconColor: theme.primaryColor,
            onTap: () {
              Navigator.pushNamed(context, '/languageSelection');
            },
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.people,
            title: _localText(context, (l) => l.manageCategory),
            iconColor: Colors.orange,
            onTap: () {
              Navigator.pushNamed(context, '/manageCategory');
            },
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.campaign,
            title: _localText(context, (l) => l.systemTheme),
            iconColor: Colors.red,
            onTap: () {
              Navigator.pushNamed(context, '/interfaceSettings');
            },
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.people_alt,
            title: _localText(context, (l) => l.userManagement),
            iconColor: Colors.green,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: context.read<UserCubit>().currentUser,
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.account_balance_wallet,
            title: _localText(context, (l) => l.account),
            iconColor: Colors.teal,
            onTap: () {
              Navigator.pushNamed(context, '/manageAccount');
            },
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.notifications,
            title: _localText(context, (l) => l.notification),
            iconColor: Colors.orange,
            hasNotification: true,
            onTap: () {
              log('message');
              NotiService().showNotification(
                id: 1,
                title: 'Hallo',
                body: 'This is Personal App',
              );
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    bool hasNotification = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (hasNotification)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
