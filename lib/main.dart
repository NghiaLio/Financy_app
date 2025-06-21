import 'package:flutter/material.dart';
import 'home.dart';
import 'wallet.dart';
import 'settings.dart';
import 'add.dart';
import 'statiscal.dart';
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF1A1A2E),
      ),
      home: ExpenseTrackerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  int _currentIndex = 0;

  void _toggleBottomNavigationBar(index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _pages =  [
    Home(),
    Wallet(),
    Add(),
    Statiscal(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF1A1A2E),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        onTap: _toggleBottomNavigationBar,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Sổ giao dịch',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Ví tiền'),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Colors.white),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }
}
