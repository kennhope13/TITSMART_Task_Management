import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/app_repository.dart';
import 'features/auth/login_screen.dart';
import 'features/main_navigation/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final repo = AppRepository();
  await repo.tryAutoLogin();

  runApp(const TitSmartApp());
}

class TitSmartApp extends StatelessWidget {
  const TitSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();

    return MaterialApp(
      title: 'TITSMART Work Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: repo.isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}
