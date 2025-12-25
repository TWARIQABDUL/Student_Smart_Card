import 'dart:io'; // 🚀 IMPORT PLATFORM
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/smart_card_service.dart';
import '../services/theme_manager.dart';
import '../services/qr_service.dart';
import 'student_history_screen.dart';
import 'login_screen.dart';

class StudentDashboard extends StatefulWidget {
  final User user;
  const StudentDashboard({super.key, required this.user});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final SmartCardService _cardService = SmartCardService();

  // --- NAVIGATION STATE ---
  int _selectedIndex = 0;

  // --- NFC STATE ---
  bool _isActive = false;
  int _nfcStatus = -1;

  // --- DYNAMIC QR STATE ---
  String _dynamicQrData = "Loading...";
  Timer? _qrTimer;

  @override
  void initState() {
    super.initState();
    _checkHardware();

    // Start QR Timer
    _updateQr();
    _qrTimer = Timer.periodic(const Duration(seconds: 30), (t) => _updateQr());
  }

  @override
  void dispose() {
    _qrTimer?.cancel();
    super.dispose();
  }

  void _updateQr() {
    if (mounted) {
      setState(() {
        _dynamicQrData = QrService.generateDynamicToken(
            widget.user.id.toString(),
            widget.user.qrSecret
        );
      });
      print("QR Updated!${widget.user.qrSecret}");
    }
  }

  Future<void> _checkHardware() async {
    // 1. Get Status (Returns 2 for iOS/Simulation)
    int status = await _cardService.checkNfcStatus();
    if (mounted) setState(() => _nfcStatus = status);

    // 2. 🚀 CRITICAL: Always save data to Secure Storage (Hybrid Sync)
    // This ensures offline mode works on iOS even without NFC activation
    await _cardService.saveUserData(widget.user);

    // 3. Only Activate NFC if hardware is ready (Android)
    if (status == 0 && widget.user.isActive) {
      _activateCard();
    }
  }

  Future<void> _activateCard() async {
    if (_nfcStatus != 0) return;
    String result = await _cardService.activateCard(widget.user);
    if (mounted) setState(() => _isActive = (result == "Card Activated" || result == "Success"));
  }

  Future<void> _deactivateCard() async {
    await _cardService.deactivateCard();
    if (mounted) setState(() => _isActive = false);
  }

  void _handleLogout() {
    Provider.of<ThemeManager>(context, listen: false).resetTheme();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  // --- MAIN BUILD ---
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildWalletPage(theme),
          const StudentHistoryScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: theme.backgroundColor,
          elevation: 0,
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(),
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: "My Wallet",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: "Access Logs",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletPage(ThemeManager theme) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.user.campus?.name ?? "My Wallet",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildNfcStatusChip(),
            const SizedBox(height: 25),
            _buildDigitalCard(theme),
            const SizedBox(height: 40),

            // 🚀 HIDE BUTTON ON IOS (NfcStatus == 2)
            if (_nfcStatus != 2)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isActive ? _deactivateCard : _activateCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isActive
                        ? Colors.redAccent.withOpacity(0.2)
                        : theme.primaryColor,
                    foregroundColor: _isActive ? Colors.redAccent : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: _isActive ? 0 : 8,
                    side: _isActive ? const BorderSide(color: Colors.redAccent) : BorderSide.none,
                  ),
                  child: Text(
                    _isActive ? "DEACTIVATE NFC" : "TAP TO PAY",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNfcStatusChip() {
    Color color = Colors.grey;
    String text = "CHECKING...";
    IconData icon = Icons.hourglass_empty;

    // Check for iOS Simulation Flag
    bool isIos = Platform.isIOS || SmartCardService.isIosSimulation;

    if (_nfcStatus == 0) {
      color = Colors.greenAccent;
      text = "NFC READY";
      icon = Icons.check_circle;
    } else if (_nfcStatus == 1) {
      color = Colors.orangeAccent;
      text = "NFC DISABLED";
      icon = Icons.settings_remote;
    } else if (_nfcStatus == 2) {
      // 🚀 CUSTOMIZE FOR IOS
      if (isIos) {
        color = Colors.cyanAccent;
        text = "QR MODE ACTIVE";
        icon = Icons.qr_code_2;
      } else {
        color = Colors.redAccent;
        text = "NFC NOT SUPPORTED";
        icon = Icons.error_outline;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDigitalCard(ThemeManager theme) {
    // Check for iOS Simulation Flag
    bool isIos = Platform.isIOS || SmartCardService.isIosSimulation;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (_isActive)
          Positioned(
            bottom: -10,
            child: Container(
              width: 280,
              height: 50,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                      color: theme.primaryColor,
                      blurRadius: 40,
                      spreadRadius: 5
                  )
                ],
              ),
            ),
          ),

        Container(
          height: 220,
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "Student Card",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18
                      )
                  ),

                  // 🚀 FIX: Use 'Icons.wifi_off' because 'contactless_disabled' doesn't exist
                  Icon(
                      _nfcStatus == 0 ? Icons.contactless : Icons.wifi_off,
                      color: _nfcStatus == 0 ? Colors.white54 : Colors.redAccent.withOpacity(0.5),
                      size: 30
                  ),
                ],
              ),
              const Spacer(),

              Text(
                  "\$${widget.user.walletBalance.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.cardTextColor
                  )
              ),
              const SizedBox(height: 5),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          widget.user.name.toUpperCase(),
                          style: GoogleFonts.poppins(
                              color: theme.cardTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                          )
                      ),
                      Text(
                          widget.user.campus?.name ?? widget.user.role,
                          style: GoogleFonts.poppins(
                              color: theme.cardTextColor.withOpacity(0.8),
                              fontSize: 12
                          )
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: QrImageView(
                        data: _dynamicQrData,
                        size: 60,
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.white
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}