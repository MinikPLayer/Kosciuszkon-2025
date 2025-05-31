import 'package:flutter/material.dart';
import 'package:frontend_calculator/views/pages/login_page.dart';
import 'package:frontend_calculator/views/pages/registration_page.dart';
void main() {
  runApp(SolarCalculatorApp());
}

class SolarCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kalkulator Fotowoltaiki',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.energy_savings_leaf, size: 100, color: Colors.green),
              SizedBox(height: 20),
              Text(
                'Kalkulator Opłacalności Energii Słonecznej',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                child: Text('Zaloguj się'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
              SizedBox(height: 40),
              ElevatedButton(
                child: Text('Załóż konto'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue, 
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
