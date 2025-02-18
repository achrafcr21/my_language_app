import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'features/progress/providers/progress_provider.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
  }

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCUkC_W8ehn4Hjt2IPCmgGuHzZHgqfk5EM',
      appId: '1:616600925144:android:ffd48980ecda7da55e78ad',
      messagingSenderId: '616600925144',
      projectId: 'mylanguageapp-41cf8',
      storageBucket: 'mylanguageapp-41cf8.firebasestorage.app',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: MaterialApp(
        title: 'IdeOmas',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
      ),
    );
  }
}