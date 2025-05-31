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

  // Dropdown selections
  String? userType;
  String? voivodeship;
  String? buildingType;
  String? orientation;
  String? roofType;
  double roofAngle = 30;

  // Options
  final List<String> userTypes = [
    'Osoba prywatna', 
    'Firma', 
    'Rolnik'
  ];
  
  final List<String> voivodeships = [
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
    'Zachodniopomorskie'
  ];
  
  final List<String> buildingTypes = [
    'Dom jednorodzinny', 
    'Budynek gospodarczy', 
    'Hala przemysłowa', 
    'Gruntowa instalacja'
  ];
  
  final List<String> orientations = [
    'Południe', 
    'Wschód', 
    'Zachód', 
    'Północ', 
    'Północny zachód',
    'Południowy zachód', 
    'Południowy wschód', 
    'Północny wschód'
  ];
  
  final List<String> roofTypes = [
    'Dachówka ceramiczna', 
    'Blachodachówka', 
    'Papa', 
    'Blacha trapezowa', 
    'Inne'
  ];

  void _register() {
    if (_formKey.currentState!.validate()) {
      // TODO: Wyślij dane do backendu lub przejdź do kalkulatora
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Rejestracja zakończona pomyślnie!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejestracja'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value != null && value.contains('@') 
                    ? null 
                    : 'Podaj poprawny email',
              ),
              
              // Hasło
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Hasło'),
                obscureText: true,
                validator: (value) => value != null && value.length >= 6 
                    ? null 
                    : 'Hasło musi mieć min. 6 znaków',
              ),
              
              const SizedBox(height: 20),

              // Typ użytkownika
              DropdownButtonFormField<String>(
                value: userType,
                hint: const Text("Wybierz typ użytkownika"),
                items: userTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (value) => setState(() => userType = value),
                validator: (value) => value == null 
                    ? 'Wybierz typ użytkownika' 
                    : null,
              ),

              // Województwo
              DropdownButtonFormField<String>(
                value: voivodeship,
                hint: const Text("Wybierz województwo"),
                items: voivodeships.map((voiv) => DropdownMenuItem(
                  value: voiv,
                  child: Text(voiv),
                )).toList(),
                onChanged: (value) => setState(() => voivodeship = value),
                validator: (value) => value == null 
                    ? 'Wybierz województwo' 
                    : null,
              ),

              // Typ budynku
              DropdownButtonFormField<String>(
                value: buildingType,
                hint: const Text("Wybierz typ budynku"),
                items: buildingTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (value) => setState(() => buildingType = value),
                validator: (value) => value == null 
                    ? 'Wybierz typ budynku' 
                    : null,
              ),

              TextField(
                decoration: InputDecoration(labelText: "Pojemność obecnych magazynów energii(kWh)"),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers can be entered
              ),

              TextField(
                decoration: InputDecoration(labelText: "Od ilu lat posiadasz obecne magazyny energii?"),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers can be entered
              ),

              // Orientacja budynku
              DropdownButtonFormField<String>(
                value: orientation,
                hint: const Text("Wybierz orientację budynku"),
                items: orientations.map((ori) => DropdownMenuItem(
                  value: ori,
                  child: Text(ori),
                )).toList(),
                onChanged: (value) => setState(() => orientation = value),
                validator: (value) => value == null 
                    ? 'Wybierz orientację' 
                    : null,
              ),

              // Pokrycie dachu
              DropdownButtonFormField<String>(
                value: roofType,
                hint: const Text("Wybierz pokrycie dachu"),
                items: roofTypes.map((roof) => DropdownMenuItem(
                  value: roof,
                  child: Text(roof),
                )).toList(),
                onChanged: (value) => setState(() => roofType = value),
                validator: (value) => value == null 
                    ? 'Wybierz pokrycie dachu' 
                    : null,
              ),

              // Kąt nachylenia
              const SizedBox(height: 20),
              Text('Kąt nachylenia dachu: ${roofAngle.toInt()}°'),
              Slider(
                value: roofAngle,
                min: 0,
                max: 60,
                divisions: 60,
                label: '${roofAngle.toInt()}°',
                onChanged: (value) => setState(() => roofAngle = value),
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Zarejestruj się'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}