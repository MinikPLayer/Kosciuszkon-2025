import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend_calculator/data/models/API.dart';

import 'package:http/http.dart' as http;

class FvEconomyChartData {
  final double upfrontInvestmentCost;
  final List<Map<String, double>> yearlyResults;

  FvEconomyChartData({required this.upfrontInvestmentCost, required this.yearlyResults});
}

class FvEconomyChartInputData {
  double singleYearEnergyConsumption = 1713.0;
  double firstYearEnergyBuyingPrice = 1.23;
  double firstYearEnergySellingPrice = 0.5162;
  double fvSystemInstallationCostPerKw = 5000.0;
  double fvSystemSizeKw = 1.5;
  double yearlyEnergyPriceIncreasePercentage = 7.1;

  double energyStorageCapacity = 1.0;
  double energyStorageInstallationCostPerKw = 2000.0;
  int calculationYears = 40;
}

class FvEconomyChartWidget extends StatelessWidget {
  // Wyniki
  final double upfrontInvestmentCost;
  final List<Map<String, double>> yearlyResults;

  final bool showTable;

  const FvEconomyChartWidget({
    super.key,
    required this.upfrontInvestmentCost,
    required this.yearlyResults,
    required this.showTable,
  });

  static double _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static Future<FvEconomyChartData?> calculate(BuildContext context, FvEconomyChartInputData inputData) async {
    try {
      // final storageCapacity = widget.userData != null
      //   ? double.tryParse(widget.userData!['storageCapacity']) ?? 0.0
      //   : 0.0;
      // final storageYears = widget.userData != null
      //   ? double.tryParse(widget.userData!['storageYears']) ?? 0.0
      //   : 0.0;
      final response = await http
          .post(
            Uri.parse(Api.calculateEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'parameters': {
                'fv_system_size_kw': inputData.fvSystemSizeKw,
                'energy_storage_size_kwh': inputData.energyStorageCapacity, // storageCapacity,
                'single_year_consumption_kwh': inputData.singleYearEnergyConsumption,
                'first_year_energy_buying_price': inputData.firstYearEnergyBuyingPrice,
                'first_year_energy_selling_price': inputData.firstYearEnergySellingPrice,
                'fv_system_installation_cost_per_kw': inputData.fvSystemInstallationCostPerKw,
                'es_system_installation_cost_per_kw': inputData.energyStorageInstallationCostPerKw,
                'yearly_energy_price_increase_percentage': inputData.yearlyEnergyPriceIncreasePercentage,
                'fv_degradation_percentage_per_year': 0.5,
                'energy_storage_degradation_percentage_per_year': 0.5,
                'years': inputData.calculationYears,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Safely parse the response data
        var upfrontInvestmentCost = _parseDouble(data['upfront_investment_cost']);
        var yearlyResults =
            (data['results_per_year'] as List).map<Map<String, double>>((yearData) {
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

        return FvEconomyChartData(upfrontInvestmentCost: upfrontInvestmentCost, yearlyResults: yearlyResults);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connection error: $e')));
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
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
                                  color: (year['without_pv']! - year['with_pv_full']!) > 0 ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                  width: MediaQuery.sizeOf(context).width / 3 / entries.length,
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
                                        'Zysk: \n${(entries[groupIndex]['without_pv']! - entries[groupIndex]['with_pv_full']!).toStringAsFixed(2)} zł\n',
                                    style: const TextStyle(color: Colors.green, fontSize: 12),
                                  ),
                                  TextSpan(
                                    text: 'Bez paneli: \n${entries[groupIndex]['without_pv']!.toStringAsFixed(2)} zł\n',
                                    style: const TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                  TextSpan(
                                    text: 'Z panelami: \n${entries[groupIndex]['with_pv']!.toStringAsFixed(2)} zł\n',
                                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                                  ),
                                  TextSpan(
                                    text:
                                        'Całkowity koszt z panelami: \n${entries[groupIndex]['with_pv_full']!.toStringAsFixed(2)} zł',
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
              if (showTable) const Text('Tabela obliczeń', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (showTable) const SizedBox(height: 16),
              if (showTable)
                Text(
                  'Koszt inwestycji: ${upfrontInvestmentCost.toStringAsFixed(2)} PLN',
                  style: const TextStyle(fontSize: 16),
                ),
              if (showTable) const SizedBox(height: 20),
              if (showTable) const Text('Roczne koszty energii:', style: TextStyle(fontWeight: FontWeight.bold)),
              if (showTable) const SizedBox(height: 8),
              if (showTable)
                Table(
                  border: TableBorder.all(),
                  children: [
                    const TableRow(
                      children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Rok', textAlign: TextAlign.center)),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Bez PV (PLN)', textAlign: TextAlign.center)),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Z PV (PLN)', textAlign: TextAlign.center)),
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
