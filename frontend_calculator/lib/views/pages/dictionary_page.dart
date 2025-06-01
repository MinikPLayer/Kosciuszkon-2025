import 'package:flutter/material.dart';
import 'package:frontend_calculator/data/notifiers.dart';

class DictionaryPage extends StatelessWidget {
  DictionaryPage({super.key});

  final List<Map<String, String>> solarTerms = [
    {
      'term': 'Panel fotowoltaiczny',
      'definition':
          'Urządzenie przekształcające energię słoneczną na energię elektryczną za pomocą zjawiska fotowoltaicznego.',
    },
    {
      'term': 'Inwerter',
      'definition':
          'Urządzenie zmieniające prąd stały (DC) produkowany przez panele na prąd zmienny (AC) używany w domowych instalacjach.',
    },
    {
      'term': 'Net-metering',
      'definition':
          'System rozliczania energii, który pozwala właścicielom paneli słonecznych oddawać nadmiar prądu do sieci i odbierać go później.',
    },
    {
      'term': 'Efektywność panelu',
      'definition': 'Procent światła słonecznego, który panel jest w stanie zamienić na energię elektryczną.',
    },
    {
      'term': 'Moc szczytowa (kWp)',
      'definition': 'Maksymalna moc, jaką może osiągnąć panel w idealnych warunkach nasłonecznienia.',
    },
    {
      'term': 'Cień',
      'definition':
          'Element mający wpływ na produkcję energii – nawet częściowe zacienienie może znacząco zmniejszyć wydajność systemu.',
    },
    {
      'term': 'Kąt nachylenia',
      'definition': 'Optymalny kąt ustawienia paneli względem poziomu, zależny od szerokości geograficznej.',
    },
    {
      'term': 'Magazyn energii',
      'definition':
          'Akumulator lub system baterii służący do przechowywania energii elektrycznej do późniejszego użycia.',
    },
    {
      'term': 'Falownik hybrydowy',
      'definition': 'Inwerter zdolny do pracy z magazynami energii i siecią jednocześnie.',
    },
    {
      'term': 'Zjawisko fotowoltaiczne',
      'definition': 'Zjawisko fizyczne, w którym światło słoneczne powoduje przepływ prądu w półprzewodniku.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Słownik Fotowoltaiki'), leading: buildBackButton()),
      body: ListView.builder(
        itemCount: solarTerms.length,
        itemBuilder: (context, index) {
          final item = solarTerms[index];
          return ExpansionTile(
            title: Text(item['term']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [Padding(padding: const EdgeInsets.all(16.0), child: Text(item['definition']!))],
          );
        },
      ),
    );
  }
}
