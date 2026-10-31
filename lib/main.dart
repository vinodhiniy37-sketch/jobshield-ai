import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/mock_data_service.dart';
import 'screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init notice (running in resilient mock mode): $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => MockDataService(),
      child: const JobScamGuardApp(),
    ),
  );
}

class JobScamGuardApp extends StatelessWidget {
  const JobScamGuardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MockDataService>(
      builder: (context, mockService, child) {
        return MaterialApp(
          title: 'JobShield AI',
          debugShowCheckedModeBanner: false,
          themeMode: mockService.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}
