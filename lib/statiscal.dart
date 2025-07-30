import 'package:flutter/material.dart';
import 'spending.dart';
import 'income.dart';

class Statiscal extends StatefulWidget {
  const Statiscal({super.key});

  @override
  State<Statiscal> createState() => _StatiscalState();
}

class _StatiscalState extends State<Statiscal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedBarPeriod = 'Monthly';
  String selectedPiePeriod = 'Monthly';
  String selectedIncomeBarPeriod = 'Monthly';
  String selectedIncomePiePeriod = 'Monthly';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TabBar(
            controller: _tabController,
            indicatorColor: theme.primaryColor,
            indicatorWeight: 3,
            labelColor: theme.textTheme.bodyLarge?.color,
            unselectedLabelColor: theme.textTheme.bodyMedium?.color,
            labelStyle: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            tabs: [Tab(text: 'Expenses'), Tab(text: 'Income')],
          ),
        ),

        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Expenses tab
              Spending(),
              // Income tab
              Income(),
            ],
          ),
        ),
      ],
    );
  }
}
