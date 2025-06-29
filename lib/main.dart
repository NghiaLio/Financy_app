// ignore_for_file: must_be_immutable

import 'package:financy_ui/app/cubit/themeCubit.dart';
import 'package:financy_ui/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'home.dart';
import 'wallet.dart';
import 'settings.dart';
import 'add.dart';
import 'statiscal.dart';
import 'login.dart';
import 'app/theme/app_theme.dart';
import 'core/constants/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await Hive.openBox('settings');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => ThemeCubit())],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Expense Tracker',
            supportedLocales: L10n.all,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            /// 👇 Luôn fallback về tiếng Việt nếu locale không khớp
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return const Locale('vi'); // fallback mặc định
            },
            locale: state.lang,
            theme: AppTheme.lightTheme(
              primaryColor: state.color!,
              backgroundColor: AppColors.backgroundLight,
              selectedItemColor: state.color!,
              fontFamily: state.fontFamily!,
              fontSize: state.fontSize!,
            ),
            darkTheme: AppTheme.darkTheme(
              primaryColor: state.color!,
              backgroundColor: AppColors.backgroundDark,
              selectedItemColor: state.color!,
              fontFamily: state.fontFamily!,
              fontSize: state.fontSize!,
            ),
            themeMode: state.themeMode,
            home: ExpenseTrackerScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
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

  final List<Widget> _pages = [
    Home(),
    Wallet(),
    Add(),
    Statiscal(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app_local = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        currentIndex: _currentIndex,
        onTap: _toggleBottomNavigationBar,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: app_local?.transactionBook ?? 'Sổ giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: app_local?.wallet ?? 'Ví tiền',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.bottomNavigationBarTheme.selectedItemColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: theme.bottomNavigationBarTheme.backgroundColor,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: app_local?.statistics ?? 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: app_local?.settings ?? 'Cài đặt',
          ),
        ],
      ),
    );
  }
}
