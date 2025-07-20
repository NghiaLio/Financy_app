// ignore_for_file: must_be_immutable
import 'package:financy_ui/app/cubit/themeCubit.dart';
import 'package:financy_ui/features/auth/cubits/authCubit.dart';
import 'package:financy_ui/features/settings/manage_account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/firebase_options.dart';
import 'package:financy_ui/l10n/l10n.dart';
import 'package:financy_ui/myApp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'features/auth/views/login.dart';
import 'app/theme/app_theme.dart';
import 'core/constants/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/settings/manage_account/screen/add_money_source.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await dotenv.load(fileName: ".env");
  await Hive.openBox('settings');
  await Hive.openBox('jwt');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => Authcubit()),
        BlocProvider(create: (_) => ManageMoneyCubit()),
      ],
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
            initialRoute: '/',
            routes: {'/': (context) => const MainApp(),
                     '/addMoneySource': (context) => const AddMoneySourceScreen()},
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

// MainApp to route

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late String appState;
  @override
  void initState() {
    appState = Hive.box('settings').get('app_state', defaultValue: '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return appState.isEmpty ? Login() : ExpenseTrackerScreen();
  }
}
