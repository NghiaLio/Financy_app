// ignore_for_file: deprecated_member_use, avoid_print

import 'package:financy_ui/features/auth/cubits/authCubit.dart';
import 'package:financy_ui/features/auth/cubits/authState.dart';
import 'package:financy_ui/features/Users/models/userModels.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'core/constants/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    print(Hive.box('settings').toMap());
    super.initState();
  }

  String _localText(String Function(AppLocalizations) getter) {
    final appLocal = AppLocalizations.of(context);
    return appLocal != null ? getter(appLocal) : '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<Authcubit, Authstate>(
      builder: (context, state) {
        UserModel? user;
     
        if (state.authStatus == AuthStatus.authenticated) {
          user = state.user;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.background,
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _localText((l) => l.hello),
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        user?.name ?? '',
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chart Section
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.negativeRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _localText((l) => l.income),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                      SizedBox(width: 20),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.positiveGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _localText((l) => l.expense),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}M',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textGrey,
                                    fontSize: 10,
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                // Chỉ hiển thị T1 đến T6
                                if (value >= 1 && value <= 6) {
                                  return Text(
                                    'Month ${value.toInt()}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textGrey,
                                      fontSize: 10,
                                    ),
                                  );
                                }
                                return SizedBox.shrink(); // Ẩn các tháng khác
                              },
                              interval: 1, // Hiển thị mỗi tháng
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(1, 15),
                              FlSpot(2, 25),
                              FlSpot(3, 18),
                              FlSpot(4, 30),
                              FlSpot(5, 12),
                              FlSpot(6, 28),
                            ],
                            isCurved: true,
                            color: Colors.pink,
                            barWidth: 2,
                            dotData: FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: [
                              FlSpot(1, 8),
                              FlSpot(2, 12),
                              FlSpot(3, 15),
                              FlSpot(4, 10),
                              FlSpot(5, 20),
                              FlSpot(6, 18),
                            ],
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 2,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Transaction List
            Expanded(
              child: ListView(
                children: [
                  _buildDateHeader('22/04/2022', 'Friday', context),
                  _buildTransactionItem(
                    context: context,
                    icon: Icons.restaurant,
                    iconColor: Colors.orange,
                    title: 'Dining',
                    subtitle: 'Personal',
                    amount: '-100,000 đ',
                  ),
                  _buildTransactionItem(
                    context: context,
                    icon: Icons.family_restroom,
                    iconColor: Colors.blue,
                    title: 'Travel',
                    subtitle: 'Family',
                    amount: '-5,000,000 đ',
                  ),
                  _buildTransactionItem(
                    context: context,
                    icon: Icons.monetization_on,
                    iconColor: Colors.green,
                    title: 'Salary',
                    subtitle: 'Personal',
                    amount: '+30,000,000 đ',
                    isPositive: true,
                  ),

                  _buildDateHeader('25/04/2022', 'Monday', context),
                  _buildTransactionItem(
                    context: context,
                    icon: Icons.medical_services,
                    iconColor: Colors.yellow,
                    title: 'Medical',
                    subtitle: 'Pets',
                    amount: '-500,000 Đ',
                  ),
                  _buildTransactionItem(
                    context: context,
                    icon: Icons.directions_bus,
                    iconColor: Colors.blue,
                    title: 'Transport',
                    subtitle: 'Personal',
                    amount: '-20,000 Đ',
                  ),
                  _buildTransactionItem(
                    context: context,
                    icon: Icons.receipt,
                    iconColor: Colors.grey,
                    title: 'Water Bill',
                    subtitle: 'Personal',
                    amount: '-300,000 Đ',
                  ),

                  _buildDateHeader('22/04/2022', 'Friday', context),
                  _buildTransactionItem(
                    context: context,
                    icon: Icons.pets,
                    iconColor: Colors.green,
                    title: 'Pet Care',
                    subtitle: '',
                    amount: '-500,000 Đ',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(String date, String day, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
          ),
          Text(
            day,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    bool isPositive = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 12),
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
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isPositive ? AppColors.positiveGreen : null,
                ),
              ),
              Text(
                'Ví của tôi',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
