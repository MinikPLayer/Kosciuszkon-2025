import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class MeasurementsPage extends StatefulWidget {
  MeasurementsPage({super.key});

  @override
  State<MeasurementsPage> createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  late final WebSocketChannel channel;

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
      appBar: AppBar(title: const Text('Measurements')),
      body: StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            try {
              debugPrint('📦 Dane odebrane z WebSocket: ${snapshot.data}');

              final decoded = json.decode(snapshot.data as String);
              if (decoded is Map && decoded.containsKey('measurements')) {
                final List measurements = decoded['measurements'];

                return ListView.builder(
                  itemCount: measurements.length,
                  itemBuilder: (context, index) {
                    final m = measurements[index];
                    return ListTile(
                      title: Text("Sensor: ${m['sensor']}"),
                      subtitle: Text("Value: ${m['value']} at ${m['saved_at']}"),
                    );
                  },
                );
              } else {
                return const Center(child: Text('⚠️ Niepoprawny format danych'));
              }
            } catch (e, stack) {
              debugPrint('❌ Błąd dekodowania JSON: $e\n$stack');
              return Center(child: Text('❌ Błąd JSON: $e'));
            }
          } else if (snapshot.hasError) {
            debugPrint('❌ Błąd WebSocket: ${snapshot.error}');
            return Center(child: Text('❌ WebSocket error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
