import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiUrl = 'http://127.0.0.1:8000/api/calculate/'; 

  // Dane wejściowe
  double singleYearEnergyConsumption = 1713.0;
  double firstYearEnergyBuyingPrice = 1.23;
  double firstYearEnergySellingPrice = 0.5162;
  double fvSystemInstallationCostPerKw = 5000.0;
  double fvSystemSizeKw = 1.0;
  double yearlyEnergyPriceIncreasePercentage = 7.1;
  int calculationYears = 10;

  // Wyniki
  double upfrontInvestmentCost = 0.0;
  List<Map<String, double>> yearlyResults = [];
  bool isLoading = false;

Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      yearlyResults.clear();
    });

    try {
      // final storageCapacity = widget.userData != null 
      //   ? double.tryParse(widget.userData!['storageCapacity']) ?? 0.0
      //   : 0.0;
      // final storageYears = widget.userData != null 
      //   ? double.tryParse(widget.userData!['storageYears']) ?? 0.0
      //   : 0.0; 
      //TODO Jakbyśmy chcieli pobierać rzeczywiste dane użytkownika, to byśmy musieli dodać odpowiednie pola do widgetu
      final storageCapacity = 10.0; // Przykładowa wartość
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'parameters': {
            'fv_system_size_kw': fvSystemSizeKw,
            'energy_storage_size_kwh':storageCapacity, // storageCapacity,
            'first_year_energy_buying_price': firstYearEnergyBuyingPrice,
            'first_year_energy_selling_price': firstYearEnergySellingPrice,
            'fv_system_installation_cost_per_kw': fvSystemInstallationCostPerKw,
            'yearly_energy_price_increase_percentage': yearlyEnergyPriceIncreasePercentage,
            'fv_degradation_percentage_per_year': 0.5,
            'energy_storage_degradation_percentage_per_year': 0.5,
            'years': calculationYears,
            'default_consumption': singleYearEnergyConsumption / (24 * 365),
          }
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Safely parse the response data
        setState(() {
          upfrontInvestmentCost = _parseDouble(data['upfront_investment_cost']);
          yearlyResults = (data['results_per_year'] as List)
              .map<Map<String, double>>((yearData) {
            return {
              'year': _parseDouble(yearData['year']),
              'without_pv': _parseDouble(yearData['non_fv_price']),
              'with_pv': _parseDouble(yearData['fv_price']),
              'with_pv_full': _parseDouble(yearData['fv_price']) + upfrontInvestmentCost,
              'savings': _parseDouble(yearData['savings']),
              'es_charge_kwh': _parseDouble(yearData['es_charge_kwh'] ?? 0),
              'consumption_kwh': _parseDouble(yearData['consumption_kwh']),
              'production_kwh': _parseDouble(yearData['production_kwh']),
            };
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  double _parseDouble(dynamic value) {
  if (value is int) {
    return value.toDouble();
  } else if (value is double) {
    return value;
  } else if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulator PV')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_buildInputSection(), const SizedBox(height: 20), _buildResultsSection()],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Parametry instalacji', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildNumberInput(
              label: 'Roczne zużycie energii (kWh)',
              value: singleYearEnergyConsumption,
              onChanged: (v) => singleYearEnergyConsumption = v,
            ),
            _buildNumberInput(
              label: 'Całkowita moc instalacji (kW)',
              value: fvSystemSizeKw,
              onChanged: (v) => fvSystemSizeKw = v,
            ),
            _buildNumberInput(
              label: 'Koszt instalacji 1kW paneli (PLN/kW)',
              value: fvSystemInstallationCostPerKw,
              onChanged: (v) => fvSystemInstallationCostPerKw = v,
            ),
            _buildNumberInput(
              label: 'Liczba lat obliczeń',
              value: calculationYears.toDouble(),
              isInt: true,
              onChanged: (v) => calculationYears = v.toInt(),
            ),
            ExpansionTile(
              title: const Text('Zaawansowane'),
              childrenPadding: EdgeInsets.all(8.0),

              children: [
                _buildNumberInput(
                  label: 'Cena zakupu energii w pierwszym roku (PLN/kWh)',
                  value: firstYearEnergyBuyingPrice,
                  onChanged: (v) => firstYearEnergyBuyingPrice = v,
                ),
                _buildNumberInput(
                  label: 'Wartość sprzedaży nadmiaru energii (PLN/kWh)',
                  value: firstYearEnergySellingPrice,
                  onChanged: (v) => firstYearEnergySellingPrice = v,
                ),
                _buildNumberInput(
                  label: 'Wartość sprzedaży nadmiaru energii (PLN/kWh)',
                  value: firstYearEnergySellingPrice,
                  onChanged: (v) => firstYearEnergySellingPrice = v,
                ),
                _buildNumberInput(
                  label: 'Roczny wzrost cen energii (%)',
                  value: yearlyEnergyPriceIncreasePercentage,
                  onChanged: (v) => yearlyEnergyPriceIncreasePercentage = v,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: isLoading ? null : _calculate,
                child: const Text('Oblicz'),
              ),
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
        initialValue: isInt ? value.toInt().toString() : value.toString(),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
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
    if (yearlyResults.isEmpty) {
      return Container();
    }

    var everyNth = (yearlyResults.length / 12).ceil();
    var entries = List.generate((yearlyResults.length / everyNth).floor(), (index) => yearlyResults[index * everyNth]);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child:
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: const Text(
                          'Zysk na przestrzeni lat',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 300,
                          child: BarChart(
                            BarChartData(
                              barGroups:
                                  entries.asMap().entries.map((entry) {
                                    final index = entry.key * everyNth;
                                    final year = entry.value;
                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: (year['without_pv']! - year['with_pv_full']!),
                                          color:
                                              (year['without_pv']! - year['with_pv_full']!) > 0
                                                  ? Colors.green
                                                  : Colors.red,
                                          borderRadius: BorderRadius.circular(2),
                                          width: 200 / entries.length,
                                        ),
                                      ],
                                    );
                                  }).toList(),

                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                                        'Rok ${group.x + 1}\n',
                                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        children: [
                                          TextSpan(
                                            text:
                                                'Zysk: \n${(entries[group.x]['without_pv']! - entries[group.x]['with_pv_full']!).toStringAsFixed(2)} zł\n',
                                            style: const TextStyle(color: Colors.green, fontSize: 12),
                                          ),
                                          TextSpan(
                                            text:
                                                'Bez paneli: \n${entries[group.x]['without_pv']!.toStringAsFixed(2)} zł\n',
                                            style: const TextStyle(color: Colors.red, fontSize: 12),
                                          ),
                                          TextSpan(
                                            text:
                                                'Z panelami: \n${entries[group.x]['with_pv']!.toStringAsFixed(2)} zł\n',
                                            style: const TextStyle(color: Colors.blue, fontSize: 12),
                                          ),
                                          TextSpan(
                                            text:
                                                'Całkowity koszt z panelami: \n${entries[group.x]['with_pv_full']!.toStringAsFixed(2)} zł',
                                            style: const TextStyle(color: Colors.lightBlue, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              gridData: FlGridData(show: true),
                            ),
                          ),
                        ),
                      ),
                      const Text('Tabela obliczeń', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(
                        'Koszt inwestycji: ${upfrontInvestmentCost.toStringAsFixed(2)} PLN',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      const Text('Roczne koszty energii:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Table(
                        border: TableBorder.all(),
                        children: [
                          const TableRow(
                            children: [
                              Padding(padding: EdgeInsets.all(8.0), child: Text('Rok', textAlign: TextAlign.center)),
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
                                child: Text('Koszt całkowity z PV (PLN)', textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                          ...entries.asMap().entries.map((entry) {
                            final index = entry.key;
                            final year = entry.value;
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
                                  child: Text(year['with_pv_full']!.toStringAsFixed(2), textAlign: TextAlign.center),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
