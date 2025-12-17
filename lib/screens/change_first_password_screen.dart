import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/smart_card_service.dart';
import 'student_dashboard.dart';
// import 'guard_dashboard.dart'; // Uncomment if you have this

class ChangeFirstPasswordScreen extends StatefulWidget {
  final String email;
  final String tempPassword; // We pass this so they don't have to type it again

  const ChangeFirstPasswordScreen({
    super.key,
    required this.email,
    required this.tempPassword
  });

  @override
  State<ChangeFirstPasswordScreen> createState() => _ChangeFirstPasswordScreenState();
}

class _ChangeFirstPasswordScreenState extends State<ChangeFirstPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isObscure = true;

  void _handleChange() async {
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showSnack("Please fill all fields", Colors.redAccent);
      return;
    }

    if (newPass != confirmPass) {
      _showSnack("Passwords do not match", Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    // Call Backend
    final result = await _authService.changeFirstPassword(
        widget.email,
        widget.tempPassword,
        newPass
    );

    if (result is User) {
      // Success! Activate Card SDK
      final cardService = SmartCardService();
      await cardService.activateCard(result);

      if (!mounted) return;

      // Navigate to Dashboard
      // Check role if needed, defaulting to Student for now
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => StudentDashboard(user: result)),
              (route) => false // Remove back history
      );

    } else {
      _showSnack(result.toString(), Colors.redAccent);
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF0F111A);
    final cardColor = const Color(0xFF1E202C);
    final accentBlue = const Color(0xFF3D5CFF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // Glow Effects
            Positioned(top: -50, right: -50, child: _buildGlow(accentBlue)),
            Positioned(bottom: 50, left: -50, child: _buildGlow(Colors.purpleAccent)),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security_update_good, size: 60, color: Colors.white),
                    const SizedBox(height: 20),
                    Text(
                      "WELCOME!",
                      style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "For your security, please update your default password to continue.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 40),

                    _buildField("New Password", _newPasswordController, Icons.lock_open, cardColor),
                    const SizedBox(height: 20),
                    _buildField("Confirm Password", _confirmPasswordController, Icons.lock, cardColor),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleChange,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: accentBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text("SET PASSWORD & LOGIN", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController controller, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: controller,
        obscureText: _isObscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            icon: Icon(icon, color: Colors.grey[500]),
            suffixIcon: IconButton(
              icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
              onPressed: () => setState(() => _isObscure = !_isObscure),
            )
        ),
      ),
    );
  }

  Widget _buildGlow(Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(width: 200, height: 200, decoration: BoxDecoration(color: color.withOpacity(0.4), shape: BoxShape.circle)),
    );
  }
}