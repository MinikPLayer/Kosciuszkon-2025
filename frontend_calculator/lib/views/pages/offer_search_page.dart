import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend_calculator/data/models/offer_model.dart';
import 'package:frontend_calculator/utils.dart';
import 'package:frontend_calculator/views/widgets/offer_entry_widget.dart';

class OfferSearchPage extends StatefulWidget {
  const OfferSearchPage({super.key});

  @override
  State<OfferSearchPage> createState() => _OfferSearchPageState();
}

class _OfferSearchPageState extends State<OfferSearchPage> {
  double roofArea = 200.0;
  double budget = 30000.0;
  double yearlyConsumption = 1713.0;

  bool isLoading = false;

  List<OfferModel> results = [];

  void applySearch() {
    // TODO: Get results from API.
    var newResults = [
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

    for (var offer in newResults) {
      var areaLimit = roofArea / offer.areaPerKw;
      var priceLimit = budget / offer.pricePerKw;

      var limit = min(areaLimit, priceLimit);
      offer.fitScore = limit;
    }

    var maxFitScore = newResults.map((e) => e.fitScore).reduce((a, b) => max(a, b));
    for (var offer in newResults) {
      offer.fitScore = (offer.fitScore / maxFitScore) * 10; // Normalize to 0-10 scale
    }

    newResults.sort((a, b) => b.fitScore.compareTo(a.fitScore));

    setState(() {
      isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
        results = newResults;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oferta')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: const Text(
                      'Wyszukiwarka ofert paneli',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Utils.buildNumberInput(
                    label: "Powierzchnia dachu (m2)",
                    value: roofArea,
                    onChanged: (value) => roofArea = value,
                  ),
                  Utils.buildNumberInput(label: "Budżet (zł)", value: budget, onChanged: (value) => budget = value),
                  Utils.buildNumberInput(
                    label: "Roczne zużycie energii (kWh)",
                    value: yearlyConsumption,
                    onChanged: (value) => yearlyConsumption = value,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: applySearch,
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                      child: Text('Szukaj', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (results.isNotEmpty || isLoading)
            Expanded(
              child: Card(
                child:
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final offer = results[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: OfferEntryWidget(offer: offer, isPremium: index < 2),
                            );
                          },
                        ),
              ),
            ),
        ],
      ),
    );
  }
}
