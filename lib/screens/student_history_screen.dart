import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Add this to pubspec.yaml for formatting dates
import '../services/api_service.dart';

class StudentHistoryScreen extends StatefulWidget {
  const StudentHistoryScreen({super.key});

  @override
  State<StudentHistoryScreen> createState() => _StudentHistoryScreenState();
}

class _StudentHistoryScreenState extends State<StudentHistoryScreen> {
  final ApiService _apiService = ApiService();

  // State Variables
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Fetch Data
  Future<void> _loadHistory() async {
    final logs = await _apiService.getMyHistory();
    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  // Helper to format date (e.g., "Dec 17, 10:30 AM")
  String _formatDate(String timestamp) {
    try {
      DateTime dt = DateTime.parse(timestamp);
      return DateFormat('MMM dd, hh:mm a').format(dt);
    } catch (_) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E202C),
      appBar: AppBar(
        title: Text("Access Logs", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : _logs.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          final bool isAllowed = log['status'] == 'ALLOWED';

          return Card(
            color: Colors.white10,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isAllowed ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAllowed ? Icons.check : Icons.block,
                  color: isAllowed ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
              title: Text(
                log['gate'] ?? "Unknown Gate",
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _formatDate(log['time']),
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
              ),
              trailing: isAllowed
                  ? null
                  : Text(
                log['reason'] ?? "Denied",
                style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            "No Records Found",
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}