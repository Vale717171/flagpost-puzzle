class FlagCountry {
  final String id;
  final String countryName;
  final String capital;
  final String continent;
  final String assetPath;
  final String shortFact;

  FlagCountry({
    required this.id,
    required this.countryName,
    required this.capital,
    required this.continent,
    required this.assetPath,
    required this.shortFact,
  });

  factory FlagCountry.fromJson(Map<String, dynamic> json) {
    return FlagCountry(
      id: json['id'] as String,
      countryName: json['countryName'] as String,
      capital: json['capital'] as String,
      continent: json['continent'] as String,
      assetPath: json['assetPath'] as String,
      shortFact: json['shortFact'] as String,
    );
  }
}
