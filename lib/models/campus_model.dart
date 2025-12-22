class Campus {
  final String name;
  final String logoUrl;
  final String primaryColor;
  final String secondaryColor;
  final String backgroundColor;
  final String cardTextColor;

  Campus({
    required this.name,
    required this.logoUrl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.cardTextColor,
  });

  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      primaryColor: json['primaryColor'] ?? '#FFFFFF',
      secondaryColor: json['secondaryColor'] ?? '#000000',
      backgroundColor: json['backgroundColor'] ?? '#FFFFFF',
      cardTextColor: json['cardTextColor'] ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'backgroundColor': backgroundColor,
      'cardTextColor': cardTextColor,
    };
  }
}