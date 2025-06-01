import 'package:flutter/material.dart';
import 'package:frontend_calculator/views/pages/location_page.dart';
import 'package:frontend_calculator/views/pages/offer_search_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_calculator/views/pages/calculator_page.dart';
import 'package:frontend_calculator/views/pages/dictionary_page.dart';
import 'package:frontend_calculator/views/pages/measurements_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildWelcomeHeader(),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                // const SizedBox(height: 24),
                // _buildRecentCalculations(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          'Witaj w Evergy!',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]),
        ),
        const SizedBox(height: 8),
        Text('Ostatnie logowanie: dzisiaj', style: GoogleFonts.poppins(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Szybkie akcje:', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildActionCard(
              context,
              icon: Icons.calculate,
              title: 'Nowa kalkulacja',
              color: Colors.blue,
              page: const CalculatorPage(),
            ),
            _buildActionCard(
              context,
              icon: Icons.shopping_bag,
              title: 'Oferta',
              color: Colors.orange,
              page: const OfferSearchPage(),
            ),
            _buildActionCard(
              context,
              icon: Icons.book,
              title: 'Słownik',
              color: Colors.purple.shade100,
              page: DictionaryPage(),
            ),
            _buildActionCard(
              context,
              icon: Icons.home,
              title: 'SmartHome',
              color: Colors.purple.shade100,
              page: LocationPage(),
            ),
            _buildActionCard(
              context,
              icon: Icons.area_chart,
              title: 'Wykresy',
              color: Colors.red.shade300,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MeasurementsPage()),
                );
              },
            ),
            _buildActionCard(
              context,
              icon: Icons.history,
              title: 'Historia',
              color: Colors.green,
              onTap: () {
                // TODO: Implement history
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Historia kalkulacji')));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    Widget? page,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            onTap ??
            () {
              if (page != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => page));
              }
            },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildRecentCalculations() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Ostatnie kalkulacje:', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
  //       const SizedBox(height: 16),
  //       ListView.builder(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         itemCount: 3, // Tymczasowo - zastąp rzeczywistymi danymi
  //         itemBuilder: (context, index) {
  //           return Card(
  //             margin: const EdgeInsets.only(bottom: 12),
  //             child: ListTile(
  //               leading: const Icon(Icons.calculate, color: Colors.green),
  //               title: Text('Kalkulacja ${index + 1}'),
  //               subtitle: Text('Data: ${DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0]}'),
  //               trailing: const Icon(Icons.chevron_right),
  //               onTap: () {
  //                 // TODO: Implement calculation details
  //               },
  //             ),
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }
}
