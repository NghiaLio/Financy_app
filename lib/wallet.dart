
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'core/constants/colors.dart';

class Wallet extends StatelessWidget {
  const Wallet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app_local = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Balance Card
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(app_local.myAccount, style: theme.textTheme.titleLarge),
                  Text(
                    '50,000,000 VND',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Income Section
              Text(app_local.income, style: theme.textTheme.bodyMedium),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.positiveGreen,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.positiveGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                '+100,000,000 VND',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.positiveGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // Expense Section
              Text(app_local.expense, style: theme.textTheme.bodyMedium),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.negativeRed,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  // Expanded(
                  //   flex: 3,
                  //   child: Container(
                  //     height: 6,
                  //     decoration: BoxDecoration(
                  //       color: AppTheme.negativeRed,
                  //       borderRadius: BorderRadius.circular(3),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.negativeRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                '-10,000,000 VND',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.negativeRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Transaction List
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildTransactionItem(
                context,
                icon: Icons.restaurant,
                iconColor: Colors.orange,
                title: 'Ăn uống',
                subtitle: 'Riêng tôi',
                amount: '-100,000 đ',
              ),
              _buildTransactionItem(
                context,
                icon: Icons.family_restroom,
                iconColor: Colors.blue,
                title: 'Du lịch',
                subtitle: 'Gia đình',
                amount: '-5,000,000 đ',
              ),
              _buildTransactionItem(
                context,
                icon: Icons.monetization_on,
                iconColor: Colors.green,
                title: 'Tiền lương',
                subtitle: 'Riêng tôi',
                amount: '+30,000,000 đ',
                isPositive: true,
              ),
              _buildTransactionItem(
                context,
                icon: Icons.medical_services,
                iconColor: Colors.yellow,
                title: 'Chữa bệnh',
                subtitle: 'Thú cưng',
                amount: '-500,000 Đ',
              ),
              _buildTransactionItem(
                context,
                icon: Icons.directions_bus,
                iconColor: Colors.blue,
                title: 'Di chuyển',
                subtitle: 'Riêng tôi',
                amount: '-20,000 Đ',
              ),
              _buildTransactionItem(
                context,
                icon: Icons.receipt,
                iconColor: Colors.grey,
                title: 'Hóa đơn nước',
                subtitle: 'Riêng tôi',
                amount: '-300,000 Đ',
              ),
              SizedBox(height: 100), // Extra space for bottom navigation
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    bool isPositive = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color:
                      isPositive
                          ? AppColors.positiveGreen
                          : theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text('Ví của tôi', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
