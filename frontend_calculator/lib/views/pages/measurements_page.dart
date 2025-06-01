import 'package:flutter/material.dart';
import 'package:frontend_calculator/data/notifiers.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class MeasurementsPage extends StatefulWidget {
  const MeasurementsPage({super.key});

  @override
  State<MeasurementsPage> createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  late final WebSocketChannel channel;
  final List<Map<String, dynamic>> _measurements = [];
  final List<Map<String, dynamic>> _sunlightData = [];
  final List<Map<String, dynamic>> _storageTempData = [];
  final ScrollController _listScrollController = ScrollController();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(Uri.parse('ws://127.0.0.1:8000/ws/measurements/'));
    _initializeSimulatedData();
  }

  void _initializeSimulatedData() {
    // Inicjalizacja symulowanych danych
    final now = DateTime.now();
    for (int i = 0; i < 20; i++) {
      final time = now.subtract(Duration(minutes: 20 - i));
      _sunlightData.add({
        'value': (50 + _random.nextDouble() * 50).toStringAsFixed(2), // 50-100%
        'saved_at': time.toIso8601String(),
      });

      _storageTempData.add({
        'value': (20 + _random.nextDouble() * 15).toStringAsFixed(2), // 20-35°C
        'saved_at': time.toIso8601String(),
      });
    }
  }

  void _addSimulatedData() {
    final now = DateTime.now();

    // Symulacja nasłonecznienia (wyższe w ciągu dnia)
    final hour = now.hour;
    double sunlightValue;
    if (hour >= 6 && hour <= 18) {
      sunlightValue = 60 + _random.nextDouble() * 40; // 60-100% w dzień
    } else {
      sunlightValue = _random.nextDouble() * 30; // 0-30% w nocy
    }

    _sunlightData.add({'value': sunlightValue.toStringAsFixed(2), 'saved_at': now.toIso8601String()});
    if (_sunlightData.length > 50) _sunlightData.removeAt(0);

    // Symulacja temperatury magazynów (zależna od nasłonecznienia)
    final storageTempValue = 20 + (sunlightValue / 100 * 20) + (_random.nextDouble() * 5 - 2.5);
    _storageTempData.add({'value': storageTempValue.toStringAsFixed(2), 'saved_at': now.toIso8601String()});
    if (_storageTempData.length > 50) _storageTempData.removeAt(0);
  }

  @override
  void dispose() {
    channel.sink.close();
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Monitoring Dashboard'),
        backgroundColor: Colors.teal.shade700,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        leading: buildBackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wykres temperatury
              _buildSectionTitle('Temperature Monitoring'),
              _buildTemperatureChart(),
              const SizedBox(height: 20),

              // Wykres nasłonecznienia
              _buildSectionTitle('Sunlight Level'),
              _buildSunlightChart(),
              const SizedBox(height: 20),

              // Wykres temperatury magazynów
              _buildSectionTitle('Energy Storage Temperature'),
              _buildStorageTempChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
    );
  }

  Widget _buildTemperatureChart() {
    return StreamBuilder(
      stream: channel.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          try {
            final decoded = json.decode(snapshot.data as String);
            if (decoded is Map && decoded.containsKey('measurements')) {
              _measurements.addAll(List<Map<String, dynamic>>.from(decoded['measurements']));
            }

            // Aktualizuj również symulowane dane
            _addSimulatedData();

            return _buildChartContent(data: _measurements, unit: '°C', color: Colors.teal, minRange: 5, maxRange: 5);
          } catch (e, stack) {
            debugPrint('❌ JSON decode error: $e\n$stack');
            return Center(child: Text('❌ JSON Error: $e'));
          }
        } else if (snapshot.hasError) {
          debugPrint('❌ WebSocket error: ${snapshot.error}');
          return Center(child: Text('❌ WebSocket Error: ${snapshot.error}'));
        }
        return _buildChartContent(data: _measurements, unit: '°C', color: Colors.teal, minRange: 5, maxRange: 5);
      },
    );
  }

  Widget _buildSunlightChart() {
    return _buildChartContent(
      data: _sunlightData,
      unit: '%',
      color: Colors.amber,
      minRange: 10,
      maxRange: 10,
      minFixed: 0,
      maxFixed: 100,
    );
  }

  Widget _buildStorageTempChart() {
    return _buildChartContent(data: _storageTempData, unit: '°C', color: Colors.deepPurple, minRange: 5, maxRange: 5);
  }

  Widget _buildChartContent({
    required List<Map<String, dynamic>> data,
    required String unit,
    required Color color,
    double minRange = 0,
    double maxRange = 0,
    double? minFixed,
    double? maxFixed,
  }) {
    final minY =
        minFixed ??
        (data.isNotEmpty
            ? (data.map((m) => double.parse(m['value'].toString())).reduce((a, b) => a < b ? a : b) - minRange)
            : 0);

    final maxY =
        maxFixed ??
        (data.isNotEmpty
            ? (data.map((m) => double.parse(m['value'].toString())).reduce((a, b) => a > b ? a : b) + maxRange)
            : 100);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: (maxY - minY) / 5,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text('${value.toStringAsFixed(1)}$unit', style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 20,
                        interval: data.length > 10 ? (data.length / 5).round().toDouble() : 1.0,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < data.length) {
                            final time = data[value.toInt()]['saved_at'].toString().substring(11, 16);
                            return Text(time, style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          data.asMap().entries.map((entry) {
                            final index = entry.key;
                            final measurement = entry.value;
                            return FlSpot(index.toDouble(), double.parse(measurement['value'].toString()));
                          }).toList(),
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final isLastPoint = index == data.length - 1;
                          return FlDotCirclePainter(
                            radius: isLastPoint ? 4 : 2,
                            color: isLastPoint ? color.withOpacity(0.9) : color.withOpacity(0.6),
                            strokeWidth: isLastPoint ? 2 : 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      shadow: Shadow(color: color.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => color.withOpacity(0.8),
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final measurement = data[spot.x.toInt()];
                          return LineTooltipItem(
                            'Value: ${spot.y.toStringAsFixed(1)}$unit\nTime: ${measurement['saved_at'].toString().substring(11, 16)}',
                            const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  minY: minY,
                  maxY: maxY,
                  minX: 0,
                  maxX: data.length > 1 ? data.length - 1 : 1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 12, color: color.withOpacity(0.9)),
                const SizedBox(width: 4),
                const Text('Latest reading', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
