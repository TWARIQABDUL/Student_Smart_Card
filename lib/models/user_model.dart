class User {
  final String name;
  final String email;
  final String nfcToken;
  final String role;
  final double walletBalance;
  final bool isActive;

  User({
    required this.name,
    required this.email,
    required this.nfcToken,
    required this.role,
    required this.walletBalance,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      nfcToken: json['nfcToken'],
      role: json['role'],
      walletBalance: (json['walletBalance'] as num).toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }
}