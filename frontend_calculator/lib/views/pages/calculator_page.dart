import 'package:flutter/material.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalkulator PV'),
      ),
      body: Center(
        child: Text(
          'Tutaj będzie kalkulator fotowoltaiki!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
