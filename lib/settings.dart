import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.translate,
              title: 'Ngôn ngữ',
              iconColor: Colors.blue,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.people,
              title: 'Quản lý thẻ loại',
              iconColor: Colors.orange,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.campaign,
              title: 'Giao diện hệ thống',
              iconColor: Colors.red,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.people_alt,
              title: 'Bạn bè',
              iconColor: Colors.purple,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.account_balance_wallet,
              title: 'Tài khoản',
              iconColor: Colors.teal,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.notifications,
              title: 'Thông báo',
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
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
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