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
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.cyan,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            tabs: [Tab(text: 'Chi tiêu'), Tab(text: 'Thu nhập')],
          ),
        ),

        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Chi tiêu tab
              Spending(),
              // Thu nhập tab
              Income(),
            ],
          ),
        ),
      ],
    );
  }
}
