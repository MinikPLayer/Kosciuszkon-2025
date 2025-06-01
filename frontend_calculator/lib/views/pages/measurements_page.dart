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
  final ScrollController _listScrollController = ScrollController();

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
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Temperature Dashboard'),
        backgroundColor: Colors.teal.shade700,
        elevation: 4,
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
              flex: 2,
              child: _buildTemperatureChart(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Latest Measurements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 1,
              child: _buildMeasurementsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureChart() {
    return StreamBuilder(
      stream: channel.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          try {
            final decoded = json.decode(snapshot.data as String);
           
            _measurements.clear();
            _measurements.add(Map<String, dynamic>.from(decoded['measurements']));
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _listScrollController.animateTo(
                _listScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            });

            return _buildChartContent();
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
    );
  }

  Widget _buildChartContent() {
    final minY = _measurements.isNotEmpty
        ? (_measurements.map((m) => double.parse(m['value'].toString()))
                .reduce((a, b) => a < b ? a : b) -
            5)
        : 0;
    final maxY = _measurements.isNotEmpty
        ? (_measurements.map((m) => double.parse(m['value'].toString()))
                .reduce((a, b) => a > b ? a : b) +
            5)
        : 100;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.teal.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 5,
                    verticalInterval: 1,
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
                        reservedSize: 40,
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
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: _measurements.length > 10
                            ? (_measurements.length / 5).round().toDouble()
                            : 1.0,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < _measurements.length) {
                            final time = _measurements[value.toInt()]['saved_at']
                                .toString()
                                .substring(11, 16);
                            return Text(
                              time,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black87),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                        color: Colors.grey.withOpacity(0.3), width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _measurements.asMap().entries.map((entry) {
                        final index = entry.key;
                        final measurement = entry.value;
                        return FlSpot(
                            index.toDouble(),
                            double.parse(
                                measurement['value'].toString()));
                      }).toList(),
                      isCurved: true,
                      color: Colors.teal.shade700,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final isLastPoint =
                              index == _measurements.length - 1;
                          return FlDotCirclePainter(
                            radius: isLastPoint ? 5 : 3,
                            color: isLastPoint
                                ? Colors.orange.shade700
                                : Colors.teal.shade900,
                            strokeWidth: isLastPoint ? 3 : 2,
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
                      shadow: Shadow(
                        color: Colors.teal.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
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
                            '${measurement['sensor']}\nTemp: ${spot.y.toStringAsFixed(1)}°C\nTime: ${measurement['saved_at'].toString().substring(11, 16)}',
                            const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  minY: minY.toDouble(),
                  maxY: maxY.toDouble(),
                  minX: 0,
                  maxX: _measurements.length > 1 ? _measurements.length - 1 : 1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle,
                    size: 12, color: Colors.orange.shade700),
                const SizedBox(width: 4),
                const Text('Latest reading',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsList() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.teal.withOpacity(0.3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _measurements.isEmpty
            ? const Center(
                child: Text('No measurements available'),
              )
            : ListView.builder(
                controller: _listScrollController,
                padding: const EdgeInsets.all(8),
                itemCount: _measurements.length,
                reverse: true,
                itemBuilder: (context, index) {
                  final reversedIndex = _measurements.length - 1 - index;
                  final measurement = _measurements[reversedIndex];
                  final isLatest = reversedIndex == _measurements.length - 1;
                  final temp = double.parse(measurement['value'].toString());
                  final time = measurement['saved_at'].toString().substring(11, 16);

                  return Container(
                    decoration: BoxDecoration(
                      color: isLatest
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.transparent,
                      border: isLatest
                          ? Border.all(color: Colors.orange.withOpacity(0.3))
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.thermostat,
                        color: isLatest
                            ? Colors.orange.shade700
                            : Colors.teal.shade700,
                      ),
                      title: Text(
                        '${temp.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isLatest
                              ? Colors.orange.shade800
                              : Colors.teal.shade800,
                        ),
                      ),
                      subtitle: Text(
                        'Sensor: ${measurement['sensor']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            time,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            measurement['saved_at']
                                .toString()
                                .substring(0, 10),
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}