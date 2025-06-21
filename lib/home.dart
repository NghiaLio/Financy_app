import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi,',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    'Minh Hoa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
            color: Color(0xFF2A2A3E),
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
                      color: Colors.pink,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Thu nhập',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Chi tiêu',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
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
                              style: TextStyle(
                                color: Colors.white70,
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
                                'Tháng ${value.toInt()}',
                                style: TextStyle(
                                  color: Colors.white70,
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
              _buildDateHeader('22/04/2022', 'Thứ sáu'),
              _buildTransactionItem(
                icon: Icons.restaurant,
                iconColor: Colors.orange,
                title: 'Ăn uống',
                subtitle: 'Riêng tôi',
                amount: '-100,000 đ',
              ),
              _buildTransactionItem(
                icon: Icons.family_restroom,
                iconColor: Colors.blue,
                title: 'Du lịch',
                subtitle: 'Gia đình',
                amount: '-5,000,000 đ',
              ),
              _buildTransactionItem(
                icon: Icons.monetization_on,
                iconColor: Colors.green,
                title: 'Tiền lương',
                subtitle: 'Riêng tôi',
                amount: '+30,000,000 đ',
                isPositive: true,
              ),

              _buildDateHeader('25/04/2022', 'Thứ hai'),
              _buildTransactionItem(
                icon: Icons.medical_services,
                iconColor: Colors.yellow,
                title: 'Chữa bệnh',
                subtitle: 'Thú cưng',
                amount: '-500,000 Đ',
              ),
              _buildTransactionItem(
                icon: Icons.directions_bus,
                iconColor: Colors.blue,
                title: 'Di chuyển',
                subtitle: 'Riêng tôi',
                amount: '-20,000 Đ',
              ),
              _buildTransactionItem(
                icon: Icons.receipt,
                iconColor: Colors.grey,
                title: 'Hóa đơn nước',
                subtitle: 'Riêng tôi',
                amount: '-300,000 Đ',
              ),

              _buildDateHeader('22/04/2022', 'Thứ sáu'),
              _buildTransactionItem(
                icon: Icons.pets,
                iconColor: Colors.green,
                title: 'Chăm sóc thú cưng',
                subtitle: '',
                amount: '-500,000 Đ',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(String date, String day) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text(day, style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    bool isPositive = false,
  }) {
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Ví của tôi',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
