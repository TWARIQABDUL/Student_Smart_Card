import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/smart_card_service.dart';
import '../models/user_model.dart';
import 'student_dashboard.dart';
// --- NEW IMPORTS ---
import 'forgot_password_screen.dart';
import 'change_first_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isObscure = true;
  bool _rememberMe = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields");
      setState(() => _isLoading = false);
      return;
    }

    // Call Backend
    final result = await _authService.login(email, password);

    if (result is User) {
      // --- CASE 1: NORMAL LOGIN SUCCESS ---

      // Activate Native SDK
      final cardService = SmartCardService();
      await cardService.activateCard(result);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.role == 'STUDENT') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => StudentDashboard(user: result)),
        );
      } else {
        _showError("Unknown Role: ${result.role}");
      }

    } else if (result is Map && result['status'] == 'FORCE_CHANGE_PASSWORD') {
      // --- CASE 2: FIRST TIME LOGIN DETECTED ---

      setState(() => _isLoading = false);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeFirstPasswordScreen(
            email: result['email'],
            tempPassword: password, // Pass current password so they don't re-type
          ),
        ),
      );

    } else {
      // --- CASE 3: ERROR ---
      setState(() => _isLoading = false);
      _showError(result.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF0F111A);
    final cardColor = const Color(0xFF1E202C);
    final accentBlue = const Color(0xFF3D5CFF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // --- 1. TOP GLOW EFFECT ---
              Positioned(
                top: -50,
                left: -50,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: accentBlue.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                right: -50,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // --- 2. MAIN CONTENT ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: Text(
                        "LOGIN TO\nYOUR ACCOUNT",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Enter your login information",
                      style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 15),

                    // Email
                    _buildCustomField(
                      controller: _emailController,
                      hint: "Email",
                      icon: Icons.email_outlined,
                      bgColor: cardColor,
                    ),
                    const SizedBox(height: 15),

                    // Password
                    _buildCustomField(
                      controller: _passwordController,
                      hint: "Password",
                      icon: Icons.lock_outline,
                      bgColor: cardColor,
                      isPassword: true,
                    ),

                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: accentBlue,
                              side: BorderSide(color: Colors.grey[600]!),
                              onChanged: (val) => setState(() => _rememberMe = val!),
                            ),
                            Text("Remember me", style: TextStyle(color: Colors.grey[400])),
                          ],
                        ),
                        // --- UPDATED BUTTON ---
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          child: Text("Forgot password", style: TextStyle(color: Colors.grey[400])),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          "LOGIN",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[800])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text("Or", style: TextStyle(color: Colors.grey[500])),
                        ),
                        Expanded(child: Divider(color: Colors.grey[800])),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: _buildSocialButton("Google", Colors.redAccent, Icons.g_mobiledata),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color bgColor,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _isObscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey[500]),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey[500]),
            onPressed: () => setState(() => _isObscure = !_isObscure),
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, Color color, IconData icon) {
    return Container(
      height: 50,
      width: 150, // Added width to make it look like a button
      decoration: BoxDecoration(
        color: const Color(0xFF1E202C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color == Colors.white ? Colors.white : color),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}