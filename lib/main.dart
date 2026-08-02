import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // 1. Import provider
import 'firebase_options.dart';
import 'providers/task_provider.dart'; // 2. Import our new provider
import 'screens/login_screen.dart';

void main() async {
  // Ensure widget binding is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Wrap MaterialApp in ChangeNotifierProvider
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        title: 'OpsBoard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          // Using the recommended layout theme structure
          appBarTheme: const AppBarTheme(centerTitle: true),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}