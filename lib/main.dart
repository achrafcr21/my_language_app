import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'screens/main_screen.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'features/progress/providers/progress_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCUkC_W8ehn4Hjt2IPCmgGuHzZHgqfk5EM',
      appId: '1:616600925144:android:ffd48980ecda7da55e78ad',
      messagingSenderId: '616600925144',
      projectId: 'mylanguageapp-41cf8',
      storageBucket: 'mylanguageapp-41cf8.firebasestorage.app',
    ),
  );
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? true;
    if (isFirstTime) {
      await prefs.setBool('first_time', false);
    }
    return isFirstTime;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IdeOmas',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkFirstTime(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.hasData && snapshot.data!) {
            return const OnboardingScreen();
          }
          
          return const MainScreen();
        },
      ),
    );
  }
}