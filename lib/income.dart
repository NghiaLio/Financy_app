import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Income extends StatefulWidget {
  const Income({super.key});

  @override
  State<Income> createState() => _IncomeState();
}

class _IncomeState extends State<Income> {
  String selectedBarPeriod = 'Monthly';
  String selectedPiePeriod = 'Monthly';
  String selectedIncomeBarPeriod = 'Monthly';
  String selectedIncomePiePeriod = 'Monthly';
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Row(
            children: [
              Text(
                'Thu nhập',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(width: 16),
              Text(
                '+60,000,000 VND',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Thống kê thu nhập theo tháng',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 16),

          // Category Filter
          Row(
            children: [
              _buildDropdown('Theo thể loại', () {}),
              SizedBox(width: 12),
              _buildDropdown(selectedIncomeBarPeriod, () {
                _showIncomePeriodDialog(true);
              }),
              SizedBox(width: 12),
              _buildDropdown('Year', () {}),
            ],
          ),
          SizedBox(height: 24),

          // Bar Chart
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          '1Jan',
                          '2Jan',
                          '3Jan',
                          '11Jan',
                          '16Jan',
                          '18Jan',
                          '20Jan',
                        ];
                        if (value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 1)
                          return Text(
                            '1M',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          );
                        if (value == 5)
                          return Text(
                            '5M',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          );
                        if (value == 10)
                          return Text(
                            '10M',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          );
                        if (value == 20)
                          return Text(
                            '20M',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          );
                        return Text('');
                      },
                      reservedSize: 32,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildIncomeBarGroup(0, 4),
                  _buildIncomeBarGroup(1, 8),
                  _buildIncomeBarGroup(2, 12),
                  _buildIncomeBarGroup(3, 6),
                  _buildIncomeBarGroup(4, 9),
                  _buildIncomeBarGroup(5, 11),
                  _buildIncomeBarGroup(6, 13),
                ],
              ),
            ),
          ),
          SizedBox(height: 32),

          // Pie Chart Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'So sánh các loại thu nhập',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Pie Chart Filters
          Row(
            children: [
              _buildDropdown(selectedIncomePiePeriod, () {
                _showIncomePeriodDialog(false);
              }),
              SizedBox(width: 12),
              _buildDropdown('Year', () {}),
            ],
          ),
          SizedBox(height: 24),

          // Pie Chart with Legend
          Row(
            children: [
              // Pie Chart
              Padding(
                padding: EdgeInsets.all(20),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.cyan,
                          value: 40,
                          title: '40%',
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          radius: 40,
                        ),
                        PieChartSectionData(
                          color: Colors.orange,
                          value: 17,
                          title: '17%',
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          radius: 40,
                        ),
                        PieChartSectionData(
                          color: Colors.purple,
                          value: 23,
                          title: '23%',
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          radius: 40,
                        ),
                        PieChartSectionData(
                          color: Colors.pink,
                          value: 20,
                          title: '20%',
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          radius: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 32),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(Colors.cyan, 'OT'),
                    SizedBox(height: 8),
                    _buildLegendItem(Colors.blue[800]!, 'Lãi cho vay'),
                    SizedBox(height: 8),
                    _buildLegendItem(Colors.purple, 'Parttime'),
                    SizedBox(height: 8),
                    _buildLegendItem(Colors.orange, 'Tiền lương chính'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A3E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: TextStyle(color: Colors.white70, fontSize: 12)),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildIncomeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.cyan,
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  void _showIncomePeriodDialog(bool isBarChart) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2A2A3E),
          title: Text('Select Period', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Monthly', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    if (isBarChart) {
                      selectedIncomeBarPeriod = 'Monthly';
                    } else {
                      selectedIncomePiePeriod = 'Monthly';
                    }
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Weekly', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    if (isBarChart) {
                      selectedIncomeBarPeriod = 'Weekly';
                    } else {
                      selectedIncomePiePeriod = 'Weekly';
                    }
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
