import 'package:flutter/material.dart';
import 'package:frontend_calculator/data/models/offer_model.dart';
import 'package:frontend_calculator/views/widgets/offer_entry_widget.dart';

class OfferResultsPage extends StatelessWidget {
  final List<OfferModel> offers;

  const OfferResultsPage({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wyniki wyszukiwania ofert')),
      body: ListView.builder(
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return OfferEntryWidget(offer: offer);
        },
      ),
    );
  }
}
