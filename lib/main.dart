import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure fonts apply globally
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Smart Pay',
      debugShowCheckedModeBanner: false,

      // Global Theme Setup
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        // This ensures the nice font is used everywhere
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xFF0F111A), // Dark background
      ),

      // Start at Login (LoginScreen will handle navigation to Dashboard)
      home: const LoginScreen(),
    );
  }
}