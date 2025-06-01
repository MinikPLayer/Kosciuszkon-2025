class OfferModel {
  String id;
  String title;
  String? description;
  String companyName;
  double fitScore;
  double pricePerKw;
  double areaPerKw;
  double temperatureLossCoefficient;
  String imageUrl;

  double fullSystemOutputKw = 0.0;
  double userYearlyConsumptionKw = 0.0;

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
    this.fullSystemOutputKw = 0.0,
  });
}
