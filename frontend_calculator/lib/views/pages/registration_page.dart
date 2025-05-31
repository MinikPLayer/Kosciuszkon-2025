import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storageCapacityController = TextEditingController();
  final _storageYearsController = TextEditingController();

  // Dropdown selections
  String? userType;
  String? voivodeship;
  String? buildingType;
  String? orientation;
  String? roofType;
  double roofAngle = 30;

  // Options
  final List<String> userTypes = ['Osoba prywatna', 'Firma', 'Rolnik'];
  final List<String> voivodeships = [
    'Dolnośląskie', 'Kujawsko-Pomorskie', 'Lubelskie', 'Lubuskie', 'Łódzkie',
    'Małopolskie', 'Mazowieckie', 'Opolskie', 'Podkarpackie', 'Podlaskie',
    'Pomorskie', 'Śląskie', 'Świętokrzyskie', 'Warmińsko-Mazurskie', 
    'Wielkopolskie', 'Zachodniopomorskie'
  ];
  final List<String> buildingTypes = [
    'Dom jednorodzinny', 'Budynek gospodarczy', 
    'Hala przemysłowa', 'Gruntowa instalacja'
  ];
  final List<String> orientations = [
    'Południe', 'Wschód', 'Zachód', 'Północ', 
    'Północny zachód', 'Południowy zachód', 
    'Południowy wschód', 'Północny wschód'
  ];
  final List<String> roofTypes = [
    'Dachówka ceramiczna', 'Blachodachówka', 
    'Papa', 'Blacha trapezowa', 'Inne'
  ];

  void _register() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement registration logic and PV calculation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Rejestracja zakończona pomyślnie! Rozpoczynamy obliczenia..."),
        ),
      );
      
      // After registration, navigate to calculation results
      // Navigator.push(context, MaterialPageRoute(builder: (context) => CalculationResults()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejestracja do kalkulatora PV'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.green[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader('Dane konta'),
                _buildEmailField(),
                _buildPasswordField(),
                
                _buildSectionHeader('Informacje o nieruchomości'),
                _buildUserTypeDropdown(),
                _buildVoivodeshipDropdown(),
                _buildBuildingTypeDropdown(),
                _buildOrientationDropdown(),
                _buildRoofTypeDropdown(),
                _buildRoofAngleSlider(),
                
                _buildSectionHeader('Obecna instalacja energetyczna'),
                _buildStorageCapacityField(),
                _buildStorageYearsField(),
                
                const SizedBox(height: 30),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
      ),
      validator: (value) => value != null && value.contains('@') 
          ? null 
          : 'Podaj poprawny email',
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: 'Hasło',
        prefixIcon: Icon(Icons.lock),
      ),
      obscureText: true,
      validator: (value) => value != null && value.length >= 6 
          ? null 
          : 'Hasło musi mieć min. 6 znaków',
    );
  }

  Widget _buildUserTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: userType,
      decoration: const InputDecoration(
        labelText: "Typ użytkownika",
        prefixIcon: Icon(Icons.person),
      ),
      items: userTypes.map((type) => DropdownMenuItem(
        value: type,
        child: Text(type),
      )).toList(),
      onChanged: (value) => setState(() => userType = value),
      validator: (value) => value == null ? 'Wybierz typ użytkownika' : null,
    );
  }

  Widget _buildVoivodeshipDropdown() {
    return DropdownButtonFormField<String>(
      value: voivodeship,
      decoration: const InputDecoration(
        labelText: "Województwo",
        prefixIcon: Icon(Icons.map),
      ),
      items: voivodeships.map((voiv) => DropdownMenuItem(
        value: voiv,
        child: Text(voiv),
      )).toList(),
      onChanged: (value) => setState(() => voivodeship = value),
      validator: (value) => value == null ? 'Wybierz województwo' : null,
    );
  }

  Widget _buildBuildingTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: buildingType,
      decoration: const InputDecoration(
        labelText: "Typ budynku",
        prefixIcon: Icon(Icons.home),
      ),
      items: buildingTypes.map((type) => DropdownMenuItem(
        value: type,
        child: Text(type),
      )).toList(),
      onChanged: (value) => setState(() => buildingType = value),
      validator: (value) => value == null ? 'Wybierz typ budynku' : null,
    );
  }

  Widget _buildOrientationDropdown() {
    return DropdownButtonFormField<String>(
      value: orientation,
      decoration: const InputDecoration(
        labelText: "Orientacja budynku",
        prefixIcon: Icon(Icons.explore),
      ),
      items: orientations.map((ori) => DropdownMenuItem(
        value: ori,
        child: Text(ori),
      )).toList(),
      onChanged: (value) => setState(() => orientation = value),
      validator: (value) => value == null ? 'Wybierz orientację' : null,
    );
  }

  Widget _buildRoofTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: roofType,
      decoration: const InputDecoration(
        labelText: "Pokrycie dachu",
        prefixIcon: Icon(Icons.roofing),
      ),
      items: roofTypes.map((roof) => DropdownMenuItem(
        value: roof,
        child: Text(roof),
      )).toList(),
      onChanged: (value) => setState(() => roofType = value),
      validator: (value) => value == null ? 'Wybierz pokrycie dachu' : null,
    );
  }

  Widget _buildRoofAngleSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Kąt nachylenia dachu: ${roofAngle.toInt()}°',
          style: const TextStyle(fontSize: 16),
        ),
        Slider(
          value: roofAngle,
          min: 0,
          max: 60,
          divisions: 60,
          activeColor: Colors.green,
          label: '${roofAngle.toInt()}°',
          onChanged: (value) => setState(() => roofAngle = value),
        ),
      ],
    );
  }

  Widget _buildStorageCapacityField() {
    return TextFormField(
      controller: _storageCapacityController,
      decoration: const InputDecoration(
        labelText: "Pojemność obecnych magazynów energii (kWh)",
        prefixIcon: Icon(Icons.battery_charging_full),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) => value?.isEmpty ?? true ? 'Podaj wartość' : null,
    );
  }

  Widget _buildStorageYearsField() {
    return TextFormField(
      controller: _storageYearsController,
      decoration: const InputDecoration(
        labelText: "Od ilu lat posiadasz obecne magazyny energii?",
        prefixIcon: Icon(Icons.calendar_today),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) => value?.isEmpty ?? true ? 'Podaj wartość' : null,
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: _register,
      child: const Text(
        'Zarejestruj się i oblicz oszczędności',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}