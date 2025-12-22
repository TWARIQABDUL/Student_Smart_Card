import 'campus_model.dart'; // 👈 IMPORT THE NEW FILE

class User {
  final int id; // 👈 Needed for QR Generation
  final String name;
  final String email;
  final String role;
  final String nfcToken;
  final String qrSecret; // 👈 Needed for HMAC Security
  final double walletBalance;
  final bool isActive;
  final Campus? campus; // 👈 Now this class exists

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.nfcToken,
    required this.qrSecret,
    required this.walletBalance,
    required this.isActive,
    this.campus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'STUDENT',
      nfcToken: json['nfcToken'] ?? '',
      qrSecret: json['qrSecret'] ?? '', // 👈 Catch the secret from backend
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      campus: json['campus'] != null ? Campus.fromJson(json['campus']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'nfcToken': nfcToken,
      'qrSecret': qrSecret,
      'walletBalance': walletBalance,
      'isActive': isActive,
      'campus': campus?.toJson(),
    };
  }
}