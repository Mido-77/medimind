import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_medicine_screen.dart';
import 'screens/medicine_detail_screen.dart';
import 'screens/history_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';
//import 'screens/settings_screen.dart';
import 'screens/change_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    _appState.init();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      appState: _appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MediCare',
        theme: AppTheme.theme,
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          OnboardingScreen.routeName: (_) => const OnboardingScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          SignupScreen.routeName: (_) => const SignupScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          AddMedicineScreen.routeName: (_) => const AddMedicineScreen(),
          MedicineDetailScreen.routeName: (_) => const MedicineDetailScreen(),
          HistoryScreen.routeName: (_) => const HistoryScreen(),
          StatisticsScreen.routeName: (_) => const StatisticsScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
          //SettingsScreen.routeName: (_) => const SettingsScreen(),
          ChangePasswordScreen.routeName: (_) => const ChangePasswordScreen(),
        },
        onUnknownRoute: (_) => MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        ),
      ),
    );
  }
}
