class OfferModel {
  final String id;
  final String title;
  final String? description;
  final String companyName;
  final double fitScore;
  final double pricePerKw;
  final double areaPerKw;
  final double temperatureLossCoefficient;
  final String imageUrl;

  OfferModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.fitScore,
    required this.pricePerKw,
    required this.areaPerKw,
    required this.temperatureLossCoefficient,
    required this.imageUrl,
    required this.description,
  });
}
