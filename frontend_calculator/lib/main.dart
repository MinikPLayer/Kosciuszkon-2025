import 'package:flutter/material.dart';
import 'package:frontend_calculator/views/pages/login_page.dart';
import 'package:frontend_calculator/views/pages/registration_page.dart';
import 'package:google_fonts/google_fonts.dart';
void main() {
  runApp(SolarCalculatorApp());
}

class SolarCalculatorApp extends StatelessWidget {
  const SolarCalculatorApp({super.key});

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.energy_savings_leaf, 
                  size: 100, 
                  color: Colors.green
                ),
                const SizedBox(height: 20),
                Text(
                  'Kalkulator Opłacalności Energii Słonecznej',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 40),
                _buildAuthButtons(context),
                const SizedBox(height: 40),
                _buildFeaturePreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Zaloguj się',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Załóż konto',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegistrationPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePreview() {
    return Column(
      children: [
        Text(
          'Odkryj możliwości:',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.green[800],
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildFeatureCard(Icons.calculate, 'Kalkulator PV'),
            _buildFeatureCard(Icons.analytics, 'Analizy'),
            _buildFeatureCard(Icons.book, 'Słownik'),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}