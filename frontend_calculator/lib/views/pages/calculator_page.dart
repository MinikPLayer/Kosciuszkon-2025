import 'package:flutter/material.dart';
import 'package:frontend_calculator/data/models/API.dart';
import 'package:frontend_calculator/data/notifiers.dart';
import 'package:frontend_calculator/utils.dart';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:frontend_calculator/views/widgets/fv_economy_chart_widget.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  // Dane wejściowe
  FvEconomyChartInputData inputData = FvEconomyChartInputData();

  double upfrontInvestmentCost = 0.0;
  List<Map<String, double>> yearlyResults = [];
  bool isLoading = false;

  bool mojPrad6 = false;
  bool ulgaTermodernizacyjna = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulator PV'), leading: buildBackButton()),
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

  Future<void> calculate() async {
    setState(() {
      isLoading = true;
      yearlyResults.clear();
    });

    var data = await FvEconomyChartWidget.calculate(context, inputData);

    setState(() {
      isLoading = false;
      if (data != null) {
        upfrontInvestmentCost = data.upfrontInvestmentCost;
        yearlyResults = data.yearlyResults;
      }
    });
  }

  Widget _buildInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Parametry instalacji', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Utils.buildNumberInput(
              label: 'Roczne zużycie energii (kWh)',
              value: inputData.singleYearEnergyConsumption,
              onChanged: (v) => inputData.singleYearEnergyConsumption = v,
            ),
            Utils.buildNumberInput(
              label: 'Liczba lat obliczeń',
              value: inputData.calculationYears.toDouble(),
              isInt: true,
              onChanged: (v) => inputData.calculationYears = v.toInt(),
            ),
            ExpansionTile(
              title: const Text('Panele fotowoltaiczne'),
              childrenPadding: EdgeInsets.all(8.0),
              maintainState: true,
              children: [
                Utils.buildNumberInput(
                  label: 'Całkowita moc instalacji (kW)',
                  value: inputData.fvSystemSizeKw,
                  onChanged: (v) => inputData.fvSystemSizeKw = v,
                ),
                Utils.buildNumberInput(
                  label: 'Koszt instalacji 1kW paneli (PLN/kW)',
                  value: inputData.fvSystemInstallationCostPerKw,
                  onChanged: (v) => inputData.fvSystemInstallationCostPerKw = v,
                ),
                Utils.buildNumberInput(
                  label: 'Roczna degradacja paneli (%)',
                  value: inputData.fvPanelDegradationPercentagePerYear,
                  onChanged: (v) => inputData.fvPanelDegradationPercentagePerYear = v,
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Magazyn energii'),
              childrenPadding: EdgeInsets.all(8.0),
              maintainState: true,
              children: [
                Utils.buildNumberInput(
                  label: 'Całkowita pojemność magazynu (kWh)',
                  value: inputData.energyStorageCapacity,
                  onChanged: (v) => inputData.energyStorageCapacity = v,
                ),
                Utils.buildNumberInput(
                  label: 'Koszt instalacji magazynu (PLN/kWh)',
                  value: inputData.energyStorageInstallationCostPerKw,
                  onChanged: (v) => inputData.energyStorageInstallationCostPerKw = v,
                ),
                Utils.buildNumberInput(
                  label: 'Roczna degradacja magazynu (%)',
                  value: inputData.energyStorageDegradationPercentagePerYear,
                  onChanged: (v) => inputData.energyStorageDegradationPercentagePerYear = v,
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Dotacje'),
              childrenPadding: EdgeInsets.all(8.0),
              maintainState: true,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: mojPrad6,
                      onChanged: (v) {
                        setState(() {
                          mojPrad6 = v ?? false;
                        });
                      },
                    ),
                    const Text('Mój prąd 6.0'),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: ulgaTermodernizacyjna,
                      onChanged: (v) {
                        setState(() {
                          ulgaTermodernizacyjna = v ?? false;
                        });
                      },
                    ),
                    const Text('Ulga termomodernizacyjna'),
                  ],
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Parametry energii'),
              childrenPadding: EdgeInsets.all(8.0),
              maintainState: true,
              children: [
                Utils.buildNumberInput(
                  label: 'Cena zakupu energii w pierwszym roku (PLN/kWh)',
                  value: inputData.firstYearEnergyBuyingPrice,
                  onChanged: (v) => inputData.firstYearEnergyBuyingPrice = v,
                ),
                Utils.buildNumberInput(
                  label: 'Wartość sprzedaży nadmiaru energii (PLN/kWh)',
                  value: inputData.firstYearEnergySellingPrice,
                  onChanged: (v) => inputData.firstYearEnergySellingPrice = v,
                ),
                Utils.buildNumberInput(
                  label: 'Roczny wzrost cen energii (%)',
                  value: inputData.yearlyEnergyPriceIncreasePercentage,
                  onChanged: (v) => inputData.yearlyEnergyPriceIncreasePercentage = v,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: isLoading ? null : calculate,
                child: const Text('Oblicz'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : FvEconomyChartWidget(
          upfrontInvestmentCost: upfrontInvestmentCost,
          yearlyResults: yearlyResults,
          showTable: true,
        );
  }
}
