import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AlarmPage extends StatelessWidget {
  final List<AlarmEvent> alarmEvents = [
    AlarmEvent(
      id: '1',
      title: 'Przekroczenie mocy!',
      description: 'Termostat w salonie przekroczył limit mocy 50W',
      deviceName: 'Termostat salon',
      location: 'Dom główny',
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      severity: AlarmSeverity.critical,
      value: '54W',
      threshold: '50W',
      type: AlarmType.powerConsumption,
    ),
    AlarmEvent(
      id: '2',
      title: 'Urządzenie nieaktywne',
      description: 'Kamera w garażu nie odpowiada od ponad 2 godzin',
      deviceName: 'Kamera garaż',
      location: 'Dom główny',
      timestamp: DateTime.now().subtract(Duration(hours: 2, minutes: 15)),
      severity: AlarmSeverity.warning,
      value: 'Nieaktywne',
      threshold: 'Odpowiedź <15min',
      type: AlarmType.deviceInactive,
    ),
    AlarmEvent(
      id: '3',
      title: 'Wysoka temperatura',
      description: 'Temperatura w serwerowni przekroczyła bezpieczny poziom',
      deviceName: 'Termostat serwerownia',
      location: 'Dom główny',
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      severity: AlarmSeverity.high,
      value: '32°C',
      threshold: '30°C',
      type: AlarmType.temperature,
    ),
    AlarmEvent(
      id: '4',
      title: 'Niski poziom baterii',
      description: 'Czujnik drzwi wejściowych ma niski poziom baterii',
      deviceName: 'Czujnik drzwi',
      location: 'Dom główny',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      severity: AlarmSeverity.medium,
      value: '15%',
      threshold: '20%',
      type: AlarmType.battery,
    ),
    AlarmEvent(
      id: '5',
      title: 'Standardowe zdarzenie',
      description: 'System wykonuje rutynową aktualizację oprogramowania',
      deviceName: 'System',
      location: 'Wszystkie lokacje',
      timestamp: DateTime.now().subtract(Duration(minutes: 30)),
      severity: AlarmSeverity.info,
      value: 'Aktualizacja',
      threshold: '',
      type: AlarmType.system,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarmy i zdarzenia'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsHeader(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: alarmEvents.length,
              itemBuilder: (context, index) {
                return _buildAlarmCard(alarmEvents[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    final criticalCount = alarmEvents.where((a) => a.severity == AlarmSeverity.critical).length;
    final warningCount = alarmEvents.where((a) => a.severity == AlarmSeverity.warning).length;
    final totalActive = criticalCount + warningCount;

    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Aktywne alarmy',
            '$totalActive',
            totalActive > 0 ? Colors.red : Colors.green,
            Icons.warning,
          ),
          _buildStatItem(
            'Krytyczne',
            '$criticalCount',
            criticalCount > 0 ? Colors.red : Colors.grey,
            Icons.error,
          ),
          _buildStatItem(
            'Ostrzeżenia',
            '$warningCount',
            warningCount > 0 ? Colors.orange : Colors.grey,
            Icons.warning_amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAlarmCard(AlarmEvent alarm) {
    final Color bgColor;
    final Color textColor;
    final IconData icon;

    switch (alarm.severity) {
      case AlarmSeverity.critical:
        bgColor = Colors.red[50]!;
        textColor = Colors.red[900]!;
        icon = Icons.error;
        break;
      case AlarmSeverity.high:
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[900]!;
        icon = Icons.warning;
        break;
      case AlarmSeverity.warning:
        bgColor = Colors.yellow[50]!;
        textColor = Colors.yellow[900]!;
        icon = Icons.warning_amber;
        break;
      case AlarmSeverity.medium:
        bgColor = Colors.blue[50]!;
        textColor = Colors.blue[900]!;
        icon = Icons.info;
        break;
      default:
        bgColor = Colors.grey[50]!;
        textColor = Colors.grey[900]!;
        icon = Icons.notifications;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: bgColor,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alarm.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(alarm.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(alarm.description),
            SizedBox(height: 8),
            if (alarm.severity.index <= AlarmSeverity.high.index)
              _buildAlarmDetails(alarm, textColor),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${alarm.location} • ${alarm.deviceName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmDetails(AlarmEvent alarm, Color textColor) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: textColor.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aktualna wartość:',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              alarm.value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Próg alarmowy:',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              alarm.threshold,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (alarm.type == AlarmType.powerConsumption)
          ElevatedButton.icon(
            onPressed: () {
              // Akcja np. wyłączenie urządzenia
            },
            icon: Icon(Icons.power_settings_new, size: 16),
            label: Text('Wyłącz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              textStyle: TextStyle(fontSize: 12),
            ),
          ),
      ],
    ),
  );
}


  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filtruj alarmy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterChip('Krytyczne', AlarmSeverity.critical),
              _buildFilterChip('Wysokie', AlarmSeverity.high),
              _buildFilterChip('Ostrzeżenia', AlarmSeverity.warning),
              _buildFilterChip('Informacje', AlarmSeverity.info),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Zastosuj'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, AlarmSeverity severity) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: FilterChip(
        label: Text(label),
        selected: true,
        onSelected: (bool selected) {},
        selectedColor: _getSeverityColor(severity).withOpacity(0.2),
        checkmarkColor: _getSeverityColor(severity),
        labelStyle: TextStyle(
          color: _getSeverityColor(severity),
        ),
      ),
    );
  }

  Color _getSeverityColor(AlarmSeverity severity) {
    switch (severity) {
      case AlarmSeverity.critical:
        return Colors.red;
      case AlarmSeverity.high:
        return Colors.orange;
      case AlarmSeverity.warning:
        return Colors.yellow[700]!;
      case AlarmSeverity.medium:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

enum AlarmSeverity {
  critical,
  high,
  warning,
  medium,
  info,
}

enum AlarmType {
  powerConsumption,
  temperature,
  deviceInactive,
  battery,
  system,
}

class AlarmEvent {
  final String id;
  final String title;
  final String description;
  final String deviceName;
  final String location;
  final DateTime timestamp;
  final AlarmSeverity severity;
  final String value;
  final String threshold;
  final AlarmType type;

  AlarmEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.deviceName,
    required this.location,
    required this.timestamp,
    required this.severity,
    required this.value,
    required this.threshold,
    required this.type,
  });
}