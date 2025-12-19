import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // 👈 IMPORT PROVIDER
import 'services/theme_manager.dart';    // 👈 IMPORT SERVICE
import 'screens/login_screen.dart';

void main() async {
  // 1. Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load the saved theme from Secure Storage
  final themeManager = ThemeManager();
  await themeManager.loadTheme();

  // 3. Run App wrapped in Provider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeManager),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Watch the ThemeManager to update colors globally
    final theme = Provider.of<ThemeManager>(context);

    return MaterialApp(
      title: 'Student Smart Pay',
      debugShowCheckedModeBanner: false,

      // 5. Use Dynamic SaaS Colors
      theme: ThemeData(
        primaryColor: theme.primaryColor,
        scaffoldBackgroundColor: theme.backgroundColor,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.primaryColor,
          background: theme.backgroundColor,
        ),
      ),

      home: const LoginScreen(),
    );
  }
}