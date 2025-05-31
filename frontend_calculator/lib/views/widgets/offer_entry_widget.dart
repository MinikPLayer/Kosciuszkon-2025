import 'package:flutter/material.dart';
import 'package:frontend_calculator/data/models/offer_model.dart';

class OfferEntryWidget extends StatelessWidget {
  final OfferModel offer;
  const OfferEntryWidget({super.key, required this.offer});

  Color getFitScoreColor(double fitScore) {
    if (fitScore >= 9.0) {
      return Colors.lightGreen;
    } else if (fitScore >= 7.0) {
      return Colors.yellow;
    } else if (fitScore >= 5.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ExpansionTile(
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset('assets/images/${offer.imageUrl}', width: 85, height: 85, fit: BoxFit.cover),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '★ ${offer.fitScore.toStringAsFixed(1)}',
                          style: TextStyle(color: getFitScoreColor(offer.fitScore)),
                        ),
                        const Text(' - '),
                        Text(offer.companyName),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          offer.pricePerKw.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const Text(' PLN / kW', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        children: [
          ListTile(title: Text(offer.description ?? '')),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Table(
              children: [
                TableRow(
                  children: [
                    Text('Cena za kW:'),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${offer.pricePerKw.toStringAsFixed(2)} PLN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Powierzchnia na kW:'),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${offer.areaPerKw.toStringAsFixed(2)} m²',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Współczynnik temperatury:'),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${offer.temperatureLossCoefficient.toStringAsFixed(2)} W / °C',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
