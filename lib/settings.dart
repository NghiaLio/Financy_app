// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'interfaceSettings.dart';
import 'languageSettings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'man_Categories_spend.dart';
import 'features/Account/screen/manageAccount.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocal = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.translate,
            title: appLocal.language,
            iconColor: theme.primaryColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguageSelectionScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.people,
            title: appLocal.manageCategory,
            iconColor: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseCategoriesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.campaign,
            title: appLocal.systemTheme,
            iconColor: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InterfaceSettings()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.people_alt,
            title: appLocal.userManagement,
            iconColor: Colors.green,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.account_balance_wallet,
            title: appLocal.account,
            iconColor: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountMoneyScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.notifications,
            title: appLocal.notification,
            iconColor: Colors.orange,
            hasNotification: true,
            onTap: () {},
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
