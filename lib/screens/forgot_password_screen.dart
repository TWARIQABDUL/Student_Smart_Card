import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart'; // <--- 1. Import Service

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final AuthService _authService = AuthService(); // <--- 2. Instantiate Service

  bool _isLoading = false;
  bool _isObscure = true;

  void _handleReset() async {
    // 1. Validate Input
    final email = _emailController.text.trim();
    final newPass = _newPasswordController.text.trim();

    if (email.isEmpty || newPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 3. Call Backend (REAL API CALL)
    String? error = await _authService.resetPassword(email, newPass);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (error == null) {
      // SUCCESS: Show green message and return to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated! Please login.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Return to Login Screen
    } else {
      // ERROR: Show red message from backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    final bgColor = const Color(0xFF0F111A);
    final cardColor = const Color(0xFF1E202C);
    final accentBlue = const Color(0xFF3D5CFF);

    return Scaffold(
      backgroundColor: bgColor,
      // Transparent AppBar so we can see the glow behind it
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // --- 1. BACKGROUND GLOW EFFECTS ---
            Positioned(
              top: -60,
              right: -60,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: accentBlue.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -40,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // --- 2. MAIN CONTENT ---
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Icon(Icons.lock_reset, size: 40, color: accentBlue),
                    ),
                    const SizedBox(height: 30),

                    // Title
                    Text(
                      "RESET\nPASSWORD",
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Enter your email and a new password to recover your account.",
                      style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    _buildCustomField(
                      controller: _emailController,
                      hint: "Registered Email",
                      icon: Icons.alternate_email,
                      bgColor: cardColor,
                    ),
                    const SizedBox(height: 20),

                    // New Password Field
                    _buildCustomField(
                      controller: _newPasswordController,
                      hint: "New Password",
                      icon: Icons.lock_outline,
                      bgColor: cardColor,
                      isPassword: true,
                    ),
                    const SizedBox(height: 40),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 10,
                          shadowColor: accentBlue.withOpacity(0.5),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          "UPDATE PASSWORD",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for TextFields
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
        ],
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
}