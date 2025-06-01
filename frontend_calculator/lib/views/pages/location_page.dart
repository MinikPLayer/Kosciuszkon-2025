import 'package:flutter/material.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LocationSelectionPage());
  }
}

// Model danych
class Location {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final bool isSelected;
  final List<Device> devices;
  final String temperature;
  final String humidity;

  Location({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.isSelected,
    required this.devices,
    required this.temperature,
    required this.humidity,
  });

  Location copyWith({
    String? id,
    String? name,
    String? address,
    String? imageUrl,
    bool? isSelected,
    List<Device>? devices,
    String? temperature,
    String? humidity,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      isSelected: isSelected ?? this.isSelected,
      devices: devices ?? this.devices,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
    );
  }
}

class Device {
  final String id;
  final String name;
  final String type;
  final String status;
  final String locationId;
  final String lastActivity;
  final String powerConsumption;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.locationId,
    required this.lastActivity,
    required this.powerConsumption,
  });
}

// Strony
class LocationSelectionPage extends StatefulWidget {
  @override
  _LocationSelectionPageState createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  List<Location> locations = [
    Location(
      id: '1',
      name: 'Dom główny',
      address: 'ul. Kwiatowa 10, Warszawa',
      imageUrl: 'https://example.com/house1.jpg',
      isSelected: true,
      devices: [
        Device(
          id: 'd1',
          name: 'Termostat salon',
          type: 'Termostat',
          status: 'Aktywny',
          locationId: '1',
          lastActivity: '2 minuty temu',
          powerConsumption: '45W',
        ),
        Device(
          id: 'd2',
          name: 'Kamera wejściowa',
          type: 'Kamera',
          status: 'Aktywna',
          locationId: '1',
          lastActivity: '1 minutę temu',
          powerConsumption: '12W',
        ),
      ],
      temperature: '22°C',
      humidity: '45%',
    ),
    Location(
      id: '2',
      name: 'Domek letniskowy',
      address: 'ul. Leśna 5, Zakopane',
      imageUrl: 'https://example.com/house2.jpg',
      isSelected: false,
      devices: [
        Device(
          id: 'd3',
          name: 'Termostat pokój główny',
          type: 'Termostat',
          status: 'Nieaktywny',
          locationId: '2',
          lastActivity: '5 godzin temu',
          powerConsumption: '0W',
        ),
      ],
      temperature: '18°C',
      humidity: '60%',
    ),
  ];

  void _selectLocation(String locationId) {
    setState(() {
      locations =
          locations.map((location) {
            return location.copyWith(isSelected: location.id == locationId);
          }).toList();
    });

    Future.delayed(Duration(milliseconds: 300), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationDetailPage(location: locations.firstWhere((loc) => loc.id == locationId)),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Twoje lokacje'),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: Icon(Icons.add), onPressed: () {})],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          return _buildLocationCard(location);
        },
      ),
    );
  }

  Widget _buildLocationCard(Location location) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: location.isSelected ? BorderSide(color: Colors.blue, width: 2) : BorderSide.none,
      ),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectLocation(location.id),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(location.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  if (location.isSelected)
                    Chip(label: Text('Wybrane', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue),
                ],
              ),
              SizedBox(height: 8),
              Text(location.address, style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DevicesListPage(location: location)),
                      );
                    },
                    child: _buildInfoChip(icon: Icons.devices, label: '${location.devices.length} urządzeń'),
                  ),
                  _buildInfoChip(icon: Icons.thermostat, label: location.temperature),
                  _buildInfoChip(icon: Icons.water_damage, label: location.humidity),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}

class LocationDetailPage extends StatelessWidget {
  final Location location;

  const LocationDetailPage({required this.location, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(location.name),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Szczegóły lokacji', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ListTile(leading: Icon(Icons.location_on), title: Text('Adres'), subtitle: Text(location.address)),
            Divider(),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DevicesListPage(location: location)));
              },
              child: ListTile(
                leading: Icon(Icons.devices),
                title: Text('Urządzenia'),
                subtitle: Text('${location.devices.length} podłączonych urządzeń'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Divider(),
            ListTile(leading: Icon(Icons.thermostat), title: Text('Temperatura'), subtitle: Text(location.temperature)),
            Divider(),
            ListTile(leading: Icon(Icons.water_damage), title: Text('Wilgotność'), subtitle: Text(location.humidity)),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Powrót do listy lokacji'),
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DevicesListPage extends StatelessWidget {
  final Location location;

  const DevicesListPage({required this.location, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Urządzenia - ${location.name}'),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: location.devices.length,
        itemBuilder: (context, index) {
          final device = location.devices[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DeviceDetailPage(device: device)));
              },
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(label: Text(device.type), backgroundColor: Colors.blue[50]),
                        SizedBox(width: 8),
                        Chip(
                          label: Text(device.status),
                          backgroundColor: device.status == 'Aktywny' ? Colors.green[50] : Colors.red[50],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('Ostatnia aktywność: ${device.lastActivity}', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DeviceDetailPage extends StatelessWidget {
  final Device device;

  const DeviceDetailPage({required this.device, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Icon(_getDeviceIcon(device.type), size: 80, color: Colors.blue)),
            SizedBox(height: 24),
            Text('Szczegóły urządzenia', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ListTile(leading: Icon(Icons.device_hub), title: Text('Typ urządzenia'), subtitle: Text(device.type)),
            Divider(),
            ListTile(leading: Icon(Icons.info), title: Text('Status'), subtitle: Text(device.status)),
            Divider(),
            ListTile(
              leading: Icon(Icons.update),
              title: Text('Ostatnia aktywność'),
              subtitle: Text(device.lastActivity),
            ),
            Divider(),
            ListTile(leading: Icon(Icons.bolt), title: Text('Pobór mocy'), subtitle: Text(device.powerConsumption)),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Powrót do listy urządzeń'),
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String type) {
    switch (type) {
      case 'Termostat':
        return Icons.thermostat;
      case 'Kamera':
        return Icons.videocam;
      case 'Oświetlenie':
        return Icons.lightbulb;
      default:
        return Icons.device_unknown;
    }
  }
}
