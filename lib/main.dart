import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(home: StudentCardScreen()));
}

class StudentCardScreen extends StatefulWidget {
  const StudentCardScreen({super.key});

  @override
  State<StudentCardScreen> createState() => _StudentCardScreenState();
}

class _StudentCardScreenState extends State<StudentCardScreen> {
  static const platform = MethodChannel('com.example.student_card_app/nfc');

  String _status = "Initializing...";
  bool _isActive = false;

  // 0 = Good, 1 = Disabled, 2 = Missing
  int _nfcHealth = -1;

  @override
  void initState() {
    super.initState();
    _checkNfcHealth();
  }

  // Calls MainActivity -> Calls AAR -> Returns Int
  Future<void> _checkNfcHealth() async {
    try {
      final int result = await platform.invokeMethod('checkNfcStatus');
      setState(() {
        _nfcHealth = result;
        if (result == 0) {
          _status = "System Ready";
        } else if (result == 1) {
          _status = "NFC is OFF";
        } else {
          _status = "No NFC Hardware";
        }
      });
    } on PlatformException catch (e) {
      setState(() {
        _status = "Error: ${e.message}";
      });
    }
  }

  Future<void> _activateCard() async {
    // Prevent activation if hardware isn't ready
    if (_nfcHealth != 0) {
      _checkNfcHealth(); // Refresh status
      return;
    }

    try {
      String studentToken = "STUDENT-ID-12345-SECURE";
      final String result = await platform.invokeMethod('startCardMode', {
        "token": studentToken
      });

      setState(() {
        _status = result;
        _isActive = true;
      });
    } on PlatformException catch (e) {
      setState(() {
        _status = "Error: '${e.message}'";
        _isActive = false;
      });
    }
  }

  Future<void> _deactivateCard() async {
    try {
      final String result = await platform.invokeMethod('stopCardMode');
      setState(() {
        _status = result;
        _isActive = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _status = "Error: '${e.message}'";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Student ID Card"),
        backgroundColor: _isActive ? Colors.green : Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                _nfcHealth == 0 ? Icons.contactless : Icons.warning_amber_rounded,
                size: 150,
                color: _isActive
                    ? Colors.green
                    : (_nfcHealth == 0 ? Colors.grey[400] : Colors.red)
            ),
            const SizedBox(height: 30),

            Text(
                _status,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _isActive ? Colors.green[800] : Colors.grey[800]
                )
            ),

            const SizedBox(height: 50),

            ElevatedButton(
              onPressed: _isActive ? _deactivateCard : _activateCard,
              style: ElevatedButton.styleFrom(
                // Button turns grey if NFC is broken/off
                backgroundColor: (_nfcHealth == 0 || _isActive)
                    ? (_isActive ? Colors.red : Colors.blue)
                    : Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: Text(
                _isActive ? "DEACTIVATE ID" : "ACTIVATE ID",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}