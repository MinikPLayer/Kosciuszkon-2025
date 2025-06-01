import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfilePage({super.key, required this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Edytowalne pola
  late TextEditingController _emailController;
  late TextEditingController _storageCapacityController;
  late TextEditingController _storageYearsController;
  late String _userType;
  late String _voivodeship;
  late String _buildingType;
  late String _orientation;
  late String _roofType;
  late double _roofAngle;

  @override
  void initState() {
    super.initState();
    // Inicjalizacja kontrolerów danymi użytkownika
    _emailController = TextEditingController(text: widget.userData['email']);
    _storageCapacityController = TextEditingController(text: widget.userData['storageCapacity']);
    _storageYearsController = TextEditingController(text: widget.userData['storageYears']);
    _userType = widget.userData['userType'];
    _voivodeship = widget.userData['voivodeship'];
    _buildingType = widget.userData['buildingType'];
    _orientation = widget.userData['orientation'];
    _roofType = widget.userData['roofType'];
    _roofAngle = widget.userData['roofAngle'];
  }

  @override
  void dispose() {
    _emailController.dispose();
    _storageCapacityController.dispose();
    _storageYearsController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zmiany zostały zapisane')));
      _toggleEdit();
      // Tutaj można dodać logikę zapisu do backendu
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (r) => false);
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      validator: (value) => value?.isEmpty ?? true ? 'To pole jest wymagane' : null,
      enabled: _isEditing,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: _isEditing ? onChanged : null,
    );
  }

  Widget _buildRoofAngleSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kąt nachylenia dachu:'),
        Slider(
          value: _roofAngle,
          min: 0,
          max: 60,
          divisions: 60,
          label: '${_roofAngle.toInt()}°',
          onChanged: _isEditing ? (value) => setState(() => _roofAngle = value) : null,
        ),
        Text(
          '${_roofAngle.toInt()}°',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mój Profil'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(icon: Icon(_isEditing ? Icons.close : Icons.edit), onPressed: _toggleEdit),
          if (_isEditing) IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green[100],
                child: const Icon(Icons.person, size: 50, color: Colors.green),
              ),
              const SizedBox(height: 16),
              Text(widget.userData['email'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Sekcja danych użytkownika
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dane użytkownika',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              const Divider(height: 16),
              _buildEditableField('Email', _emailController),
              _buildDropdown('Typ użytkownika', _userType, [
                'Osoba prywatna',
                'Firma',
                'Rolnik',
              ], (value) => setState(() => _userType = value!)),
              const SizedBox(height: 16),

              // Sekcja nieruchomości
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dane nieruchomości',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              const Divider(height: 16),
              _buildDropdown('Województwo', _voivodeship, [
                'Dolnośląskie',
                'Kujawsko-Pomorskie',
                'Lubelskie',
                'Lubuskie',
                'Łódzkie',
                'Małopolskie',
                'Mazowieckie',
                'Opolskie',
                'Podkarpackie',
                'Podlaskie',
                'Pomorskie',
                'Śląskie',
                'Świętokrzyskie',
                'Warmińsko-Mazurskie',
                'Wielkopolskie',
                'Zachodniopomorskie',
              ], (value) => setState(() => _voivodeship = value!)),
              _buildDropdown('Typ budynku', _buildingType, [
                'Dom jednorodzinny',
                'Budynek gospodarczy',
                'Hala przemysłowa',
                'Gruntowa instalacja',
              ], (value) => setState(() => _buildingType = value!)),
              _buildDropdown('Orientacja', _orientation, [
                'Południe',
                'Wschód',
                'Zachód',
                'Północ',
                'Północny zachód',
                'Południowy zachód',
                'Południowy wschód',
                'Północny wschód',
              ], (value) => setState(() => _orientation = value!)),
              _buildDropdown('Pokrycie dachu', _roofType, [
                'Dachówka ceramiczna',
                'Blachodachówka',
                'Papa',
                'Blacha trapezowa',
                'Inne',
              ], (value) => setState(() => _roofType = value!)),
              _buildRoofAngleSlider(),
              const SizedBox(height: 16),

              // Sekcja instalacji
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Obecna instalacja',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              const Divider(height: 16),
              _buildEditableField('Pojemność magazynów (kWh)', _storageCapacityController, isNumber: true),
              _buildEditableField('Lata użytkowania', _storageYearsController, isNumber: true),
              const SizedBox(height: 24),

              // Przyciski akcji
              if (!_isEditing)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _logout,
                  child: const Text('Wyloguj się'),
                ),
              const SizedBox(height: 16),

              // Link do wyników kalkulacji
              TextButton(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (context) => CalculationResultsPage(),
                  // ));
                },
                child: const Text('Zobacz historię kalkulacji', style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
