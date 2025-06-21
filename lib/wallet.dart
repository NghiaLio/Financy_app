import 'package:flutter/material.dart';

class Wallet extends StatelessWidget {
  const Wallet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Balance Card
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF2A2A3E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tài khoản của tôi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '50,000,000 VND',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Income Section
              Text(
                'Thu nhập',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.pink,
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
                        color: Colors.pink,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                '+100,000,000 VND',
                style: TextStyle(
                  color: Colors.pink,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),

              // Expense Section
              Text(
                'Chi tiêu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
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
                        color: Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                '-10,000,000 VND',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
              SizedBox(height: 100), // Extra space for bottom navigation
            ],
          ),
        ),
      ],
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
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
              SizedBox(height: 4),
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
