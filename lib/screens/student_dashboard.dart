import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/user_model.dart';
import '../services/smart_card_service.dart';
import 'student_history_screen.dart'; // <--- Import the History Screen

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
  int _nfcStatus = -1; // -1: Loading, 0: Ready, 1: Disabled, 2: Missing

  @override
  void initState() {
    super.initState();
    _checkHardware();
  }

  Future<void> _checkHardware() async {
    int status = await _cardService.checkNfcStatus();
    setState(() => _nfcStatus = status);

    if (status == 0 && widget.user.isActive) {
      _activateCard();
    }
  }

  Future<void> _activateCard() async {
    if (_nfcStatus != 0) return;
    String result = await _cardService.activateCard(widget.user);
    setState(() => _isActive = (result == "Card Activated" || result == "Success"));
  }

  Future<void> _deactivateCard() async {
    await _cardService.deactivateCard();
    setState(() => _isActive = false);
  }

  // --- MAIN BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),

      // 1. SWITCH BETWEEN PAGES
      // We use IndexedStack so the Wallet state (Active/Inactive) doesn't reset when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildWalletPage(),       // Index 0: Your Home Screen
          const StudentHistoryScreen(), // Index 1: The History Screen
        ],
      ),

      // 2. BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF0F111A),
          elevation: 0,
          selectedItemColor: const Color(0xFF3D5CFF), // Your Brand Blue
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

  // --- WALLET PAGE (Your Original UI) ---
  Widget _buildWalletPage() {
    return Scaffold( // Nested Scaffold allows us to keep the AppBar specific to this page
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("My Wallet", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false, // Hide back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildNfcStatusChip(),
            const SizedBox(height: 25),
            _buildDigitalCard(),
            const SizedBox(height: 40),

            // Action Button
            if (_nfcStatus != 2)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isActive ? _deactivateCard : _activateCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isActive ? Colors.redAccent.withOpacity(0.2) : const Color(0xFF3D5CFF),
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

  // --- HELPERS (Unchanged) ---
  Widget _buildNfcStatusChip() {
    Color color = Colors.grey;
    String text = "CHECKING...";
    IconData icon = Icons.hourglass_empty;

    if (_nfcStatus == 0) {
      color = Colors.greenAccent;
      text = "NFC READY";
      icon = Icons.check_circle;
    } else if (_nfcStatus == 1) {
      color = Colors.orangeAccent;
      text = "NFC DISABLED";
      icon = Icons.settings_remote;
    } else if (_nfcStatus == 2) {
      color = Colors.redAccent;
      text = "NFC NOT SUPPORTED";
      icon = Icons.error_outline;
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

  Widget _buildDigitalCard() {
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
                color: const Color(0xFF3D5CFF).withOpacity(0.6),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [const BoxShadow(color: Color(0xFF3D5CFF), blurRadius: 40, spreadRadius: 5)],
              ),
            ),
          ),
        Container(
          height: 220,
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isActive
                  ? [const Color(0xFF3D5CFF), const Color(0xFF2B45B5)]
                  : [const Color(0xFF2A2D3E), const Color(0xFF1E202C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _isActive ? Colors.blueAccent.withOpacity(0.5) : Colors.white10, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(_nfcStatus == 2 ? Icons.no_sim_outlined : Icons.sim_card, color: _nfcStatus == 2 ? Colors.redAccent : Colors.amber, size: 40),
                  Icon(Icons.contactless, color: _isActive ? Colors.white : Colors.white24, size: 30),
                ],
              ),
              const Spacer(),
              Text("\$${widget.user.walletBalance.toStringAsFixed(2)}", style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.user.name.toUpperCase(), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                      Text(widget.user.role, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: QrImageView(data: widget.user.nfcToken, size: 40, padding: EdgeInsets.zero, backgroundColor: Colors.white),
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