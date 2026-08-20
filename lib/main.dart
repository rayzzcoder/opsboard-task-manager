import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // <-- 1. NEW: Import AdMob
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart'; // Import the new theme provider
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // <-- 2. NEW: Initialize the Ads engine before the app starts
  await MobileAds.instance.initialize();

  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MultiProvider to provide both Task and Theme state globally
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      // Consumer listens to ThemeProvider changes and redraws MaterialApp
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'OpsBoard',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode, // Dynamically switches

            // --- LIGHT THEME ---
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blueGrey,
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(centerTitle: true),
            ),

            // --- DARK THEME ---
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blueGrey,
              brightness: Brightness.dark,
              appBarTheme: const AppBarTheme(centerTitle: true),
            ),

            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}