import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiUrl = 'http://127.0.0.1:8000/api/calculate/'; 

  // Dane wejściowe
  double _singleYearEnergyConsumption = 1713.0;
  double _firstYearEnergyBuyingPrice = 1.23;
  double _firstYearEnergySellingPrice = 0.5162;
  double _fvSystemInstallationCostPerKw = 5000.0;
  double _fvSystemSizeKw = 1.0;
  double _fvSystemOutputPercentage = 14.2;
  double _autoconsumptionPercentage = 22.0;
  double _yearlyEnergyPriceIncreasePercentage = 7.1;
  int _calculationYears = 10;

  // Wyniki
  double _upfrontInvestmentCost = 0.0;
  List<Map<String, double>> _yearlyResults = [];
  bool _isLoading = false;

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _yearlyResults.clear();
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        body: jsonEncode({'parameters': {
          'single_year_energy_consumption': _singleYearEnergyConsumption,
          'first_year_energy_buying_price': _firstYearEnergyBuyingPrice,
          'first_year_energy_selling_price': _firstYearEnergySellingPrice,
          'fv_system_installation_cost_per_kw': _fvSystemInstallationCostPerKw,
          'fv_system_size_kw': _fvSystemSizeKw,
          'fv_system_output_percentage': _fvSystemOutputPercentage,
          'autoconsumption_percentage': _autoconsumptionPercentage,
          'yearly_energy_price_increase_percentage': _yearlyEnergyPriceIncreasePercentage,
          'years': _calculationYears,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _upfrontInvestmentCost = data['upfront_investment_cost'];
          _yearlyResults = List<Map<String, double>>.from(
            data['energy_prices_per_year'].map((year) => {
              'without_pv': year['energy_price_without_fotovoltaic'],
              'with_pv': year['energy_price_with_fotovoltaic'],
            }),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd obliczeń: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd połączenia: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator PV'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputSection(),
              const SizedBox(height: 20),
              _buildResultsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _calculate,
        child: const Icon(Icons.calculate),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Parametry instalacji',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildNumberInput(
              label: 'Roczne zużycie energii (kWh)',
              value: _singleYearEnergyConsumption,
              onChanged: (v) => _singleYearEnergyConsumption = v,
            ),
            _buildNumberInput(
              label: 'Cena zakupu energii (PLN/kWh)',
              value: _firstYearEnergyBuyingPrice,
              onChanged: (v) => _firstYearEnergyBuyingPrice = v,
            ),
            _buildNumberInput(
              label: 'Cena sprzedaży energii (PLN/kWh)',
              value: _firstYearEnergySellingPrice,
              onChanged: (v) => _firstYearEnergySellingPrice = v,
            ),
            _buildNumberInput(
              label: 'Koszt instalacji PV (PLN/kW)',
              value: _fvSystemInstallationCostPerKw,
              onChanged: (v) => _fvSystemInstallationCostPerKw = v,
            ),
            _buildNumberInput(
              label: 'Wielkość instalacji (kW)',
              value: _fvSystemSizeKw,
              onChanged: (v) => _fvSystemSizeKw = v,
            ),
            _buildNumberInput(
              label: 'Wydajność instalacji (%)',
              value: _fvSystemOutputPercentage,
              onChanged: (v) => _fvSystemOutputPercentage = v,
            ),
            _buildNumberInput(
              label: 'Autokonsumpcja (%)',
              value: _autoconsumptionPercentage,
              onChanged: (v) => _autoconsumptionPercentage = v,
            ),
            _buildNumberInput(
              label: 'Roczny wzrost cen energii (%)',
              value: _yearlyEnergyPriceIncreasePercentage,
              onChanged: (v) => _yearlyEnergyPriceIncreasePercentage = v,
            ),
            _buildNumberInput(
              label: 'Liczba lat obliczeń',
              value: _calculationYears.toDouble(),
              isInt: true,
              onChanged: (v) => _calculationYears = v.toInt(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput({
    required String label,
    required double value,
    required void Function(double) onChanged,
    bool isInt = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        initialValue: value.toString(),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Wprowadź wartość';
          final numValue = isInt ? int.tryParse(value) : double.tryParse(value);
          if (numValue == null) return 'Nieprawidłowa wartość';
          if (numValue <= 0) return 'Wartość musi być dodatnia';
          return null;
        },
        onChanged: (value) {
          final numValue = isInt ? int.tryParse(value) : double.tryParse(value);
          if (numValue != null && numValue > 0) {
            onChanged(numValue.toDouble());
          }
        },
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_yearlyResults.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Wprowadź parametry i kliknij przycisk obliczeń',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Wyniki obliczeń',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Koszt inwestycji: ${_upfrontInvestmentCost.toStringAsFixed(2)} PLN',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Roczne koszty energii:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(),
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Rok', textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Bez PV (PLN)', textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Z PV (PLN)', textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Oszczędności (PLN)', textAlign: TextAlign.center),
                    ),
                  ],
                ),
                ..._yearlyResults.asMap().entries.map((entry) {
                  final index = entry.key;
                  final year = entry.value;
                  final savings = year['without_pv']! - year['with_pv']!;
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text((index + 1).toString(), textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(year['without_pv']!.toStringAsFixed(2), textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(year['with_pv']!.toStringAsFixed(2), textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(savings.toStringAsFixed(2), textAlign: TextAlign.center),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}