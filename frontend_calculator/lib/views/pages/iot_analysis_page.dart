import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class IoTAnalysisPage extends StatefulWidget {
  const IoTAnalysisPage({super.key});

  @override
  State<IoTAnalysisPage> createState() => _IoTAnalysisPageState();
}

class _IoTAnalysisPageState extends State<IoTAnalysisPage> {
  late final WebSocketChannel channel;
  List<double> temperatureReadings = [];
  bool isConnected = false;
  
  get timestamps => null;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    // Symulacja połączenia WebSocket - w rzeczywistości podaj prawdziwy URL
    channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8080/ws/temperature'), // Zmień na prawdziwy endpoint
    );

     channel.stream.listen(
      (data) {
        final jsonData = json.decode(data);
        setState(() {
          temperatureReadings.add(jsonData['temperature']);
          timestamps.add(jsonData['timestamp']);
          if (temperatureReadings.length > 50) {
            temperatureReadings.removeAt(0);
            timestamps.removeAt(0);
          }
          isConnected = true;
        });
      },
      onError: (error) {
        setState(() => isConnected = false);
        print('WebSocket error: $error');
      },
      onDone: () {
        setState(() => isConnected = false);
        print('WebSocket closed');
      },
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
        title: const Text('Monitorowanie IoT'),
        actions: [
          IconButton(
            icon: Icon(isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: () {
              if (!isConnected) {
                _connectToWebSocket();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatusCard(),
            const SizedBox(height: 20),
            _buildTemperatureChart(),
            const SizedBox(height: 20),
            _buildCurrentReading(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isConnected ? Icons.check_circle : Icons.error,
              color: isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Text(
              isConnected ? 'Połączono z czujnikiem' : 'Brak połączenia',
              style: TextStyle(
                color: isConnected ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Temperatura w czasie', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _TemperatureChartPainter(temperatureReadings),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentReading() {
    final lastTemp = temperatureReadings.isEmpty ? 0.0 : temperatureReadings.last;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Aktualna temperatura', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text(
              '${lastTemp.toStringAsFixed(1)}°C',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _getTemperatureStatus(lastTemp),
              style: TextStyle(
                color: _getTemperatureColor(lastTemp),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTemperatureStatus(double temp) {
    if (temp < 20) return 'Zimno';
    if (temp < 25) return 'Optymalnie';
    if (temp < 28) return 'Ciepło';
    return 'Gorąco';
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 20) return Colors.blue;
    if (temp < 25) return Colors.green;
    if (temp < 28) return Colors.orange;
    return Colors.red;
  }
}

class _TemperatureChartPainter extends CustomPainter {
  final List<double> temperatures;

  _TemperatureChartPainter(this.temperatures);

  @override
  void paint(Canvas canvas, Size size) {
    if (temperatures.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final minTemp = temperatures.reduce(min) - 2;
    final maxTemp = temperatures.reduce(max) + 2;
    final range = maxTemp - minTemp;

    final points = <Offset>[];
    for (var i = 0; i < temperatures.length; i++) {
      final x = size.width * (i / (temperatures.length - 1));
      final y = size.height * (1 - (temperatures[i] - minTemp) / range);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.addPolygon(points, false);
    canvas.drawPath(path, paint);

    // Punkty pomiarowe
    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}