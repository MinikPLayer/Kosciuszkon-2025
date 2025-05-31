import 'package:flutter/material.dart';
import 'package:frontend_calculator/data/models/offer_model.dart';
import 'package:frontend_calculator/views/pages/offer_results_page.dart';

class OfferSearchPage extends StatefulWidget {
  const OfferSearchPage({super.key});

  @override
  State<OfferSearchPage> createState() => _OfferSearchPageState();
}

class _OfferSearchPageState extends State<OfferSearchPage> {
  void applySearch() {
    // TODO: Get results from API.
    var results = [
      OfferModel(
        id: "0",
        title: "Panele fotowoltaiczne",
        companyName: "Panex",
        description: "Wysokiej jakości panele słoneczne o dużej wydajności.",
        fitScore: 7.9,
        pricePerKw: 4239.99,
        areaPerKw: 15.5,
        temperatureLossCoefficient: 0.8,
        imageUrl: "panel1.jpg",
      ),
      OfferModel(
        id: "1",
        title: "Instalacja fotowoltaiczna",
        companyName: "EkoEnergia",
        description: "Profesjonalna instalacja systemów fotowoltaicznych.",
        fitScore: 8.5,
        pricePerKw: 3999.99,
        areaPerKw: 17.2,
        temperatureLossCoefficient: 0.75,
        imageUrl: "panel2.jpg",
      ),
      OfferModel(
        id: "2",
        title: "Zestaw paneli słonecznych",
        companyName: "SolTech",
        description: "Kompletny zestaw paneli słonecznych z akcesoriami.",
        fitScore: 9.2,
        pricePerKw: 4599.99,
        areaPerKw: 14.8,
        temperatureLossCoefficient: 0.7,
        imageUrl: "panel3.png",
      ),
      OfferModel(
        id: "3",
        title: "System PV z magazynem energii",
        companyName: "GreenPower",
        description: "Innowacyjny system PV z magazynem energii.",
        fitScore: 9.7,
        pricePerKw: 5999.99,
        areaPerKw: 12.0,
        temperatureLossCoefficient: 0.78,
        imageUrl: "panel4.png",
      ),
      OfferModel(
        id: "4",
        title: "Panele słoneczne z montażem",
        companyName: "SolarMax",
        description: "Panele słoneczne z profesjonalnym montażem.",
        fitScore: 3.1,
        pricePerKw: 4499.99,
        areaPerKw: 21.6,
        temperatureLossCoefficient: 0.4,
        imageUrl: "panel5.png",
      ),
      OfferModel(
        id: "5",
        title: "Zestaw instalacji paneli z gwarancją",
        companyName: "EcoSolar",
        description: "Zestaw instalacji paneli z gwarancją.",
        fitScore: 6.5,
        pricePerKw: 3899.99,
        areaPerKw: 18.0,
        temperatureLossCoefficient: 0.82,
        imageUrl: "panel6.png",
      ),
    ];

    results.sort((a, b) => b.fitScore.compareTo(a.fitScore));

    Navigator.push(context, MaterialPageRoute(builder: (context) => OfferResultsPage(offers: results)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oferta')),
      body: Center(child: ElevatedButton(onPressed: applySearch, child: const Text('Test search'))),
    );
  }
}
