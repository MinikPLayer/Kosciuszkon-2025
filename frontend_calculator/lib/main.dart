import 'package:flutter/material.dart';
import 'package:frontend_calculator/views/pages/calculator_page.dart';
import 'package:frontend_calculator/views/pages/dictionary_page.dart';
import 'package:frontend_calculator/views/pages/login_page.dart';
import 'package:frontend_calculator/views/pages/offer_search_page.dart';
import 'package:frontend_calculator/views/pages/registration_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(SolarCalculatorApp());
}

class SolarCalculatorApp extends StatelessWidget {
  const SolarCalculatorApp({super.key});

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  Color mix(Color color1, Color color2, [double amount = .5]) {
    assert(amount >= 0 && amount <= 1);

    final r = (color1.red * (1 - amount) + color2.red * amount).round();
    final g = (color1.green * (1 - amount) + color2.green * amount).round();
    final b = (color1.blue * (1 - amount) + color2.blue * amount).round();

    return Color.fromARGB((color1.alpha * (1 - amount) + color2.alpha * amount).round(), r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    var darkBackgroundColor = darken(Colors.grey, 0.6);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kalkulator Fotowoltaiki',
      theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.light)),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.energy_savings_leaf, size: 100, color: Colors.green),
                const SizedBox(height: 20),
                Text(
                  'Kalkulator Opłacalności Energii Słonecznej',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]),
                ),
                const SizedBox(height: 40),
                _buildAuthButtons(context),
                const SizedBox(height: 40),
                _buildFeaturePreview(context),
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
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Zaloguj się',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Załóż konto', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage()));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePreview(BuildContext context) {
    return Column(
      children: [
        Text(
          'Odkryj możliwości:',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green[800]),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildFeatureCard(
              Icons.calculate,
              'Kalkulator',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CalculatorPage()));
              },
            ),
            _buildFeatureCard(
              Icons.shopping_bag,
              'Oferta',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OfferSearchPage()));
              },
            ),
            _buildFeatureCard(
              Icons.book,
              'Słownik',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DictionaryPage()));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, {Function()? onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(icon, size: 40, color: Colors.green),
                const SizedBox(height: 8),
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
