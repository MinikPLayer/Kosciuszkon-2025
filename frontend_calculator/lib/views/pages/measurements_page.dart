import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class MeasurementsPage extends StatefulWidget {
  const MeasurementsPage({super.key});

  @override
  State<MeasurementsPage> createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  late final WebSocketChannel channel;
  final List<Map<String, dynamic>> _measurements = [];

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(
      Uri.parse('ws://127.0.0.1:8000/ws/measurements/'),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Temperature Dashboard'),
        backgroundColor: Colors.teal.shade700,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Real-Time Temperature Monitoring',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'IoT-powered sensor data visualization',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder(
                stream: channel.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    try {
                      final decoded = json.decode(snapshot.data as String);
                      if (decoded is Map && decoded.containsKey('measurements')) {
                        _measurements.clear();
                        _measurements.addAll(
                          List<Map<String, dynamic>>.from(decoded['measurements']),
                        );
                      } else if (decoded is Map &&
                          decoded.containsKey('sensor') &&
                          decoded.containsKey('value') &&
                          decoded.containsKey('saved_at')) {
                        _measurements.add(Map<String, dynamic>.from(decoded));
                        if (_measurements.length > 50) {
                          _measurements.removeAt(0);
                        }
                      }

                      return _buildTemperatureChart();
                    } catch (e, stack) {
                      debugPrint('❌ JSON decode error: $e\n$stack');
                      return Center(child: Text('❌ JSON Error: $e'));
                    }
                  } else if (snapshot.hasError) {
                    debugPrint('❌ WebSocket error: ${snapshot.error}');
                    return Center(child: Text('❌ WebSocket Error: ${snapshot.error}'));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureChart() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 5,
              verticalInterval: 10,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: 5,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        '${value.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
                axisNameWidget: const Text(
                  'Temperature (°C)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
                axisNameSize: 30,
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 10,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < _measurements.length) {
                      final time = _measurements[value.toInt()]['saved_at']
                          .toString()
                          .substring(11, 16);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          time,
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
                axisNameWidget: const Text(
                  'Time (HH:MM)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
                axisNameSize: 30,
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: _measurements.asMap().entries.map((entry) {
                  final index = entry.key;
                  final measurement = entry.value;
                  return FlSpot(index.toDouble(), double.parse(measurement['value']));
                }).toList(),
                isCurved: true,
                color: Colors.teal.shade700,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.teal.shade900,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal.withOpacity(0.3),
                      Colors.teal.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => Colors.teal.shade800,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final measurement = _measurements[spot.x.toInt()];
                    return LineTooltipItem(
                      'Temp: ${spot.y.toStringAsFixed(1)}°C\nTime: ${measurement['saved_at'].toString().substring(11, 16)}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }).toList();
                },
              ),
            ),
            minY: _measurements.isNotEmpty
                ? (_measurements.map((m) => double.parse(m['value'])).reduce((a, b) => a < b ? a : b) - 5)
                : 0,
            maxY: _measurements.isNotEmpty
                ? (_measurements.map((m) => double.parse(m['value'])).reduce((a, b) => a > b ? a : b) + 5)
                : 100,
          ),
        ),
      ),
    );
  }
}