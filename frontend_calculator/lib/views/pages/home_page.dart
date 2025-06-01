import 'package:flutter/material.dart';
import 'package:frontend_calculator/views/pages/alarm_page.dart';
import 'package:frontend_calculator/views/pages/dictionary_page.dart';
import 'package:frontend_calculator/views/pages/location_page.dart';
import 'package:frontend_calculator/views/pages/measurements_page.dart';
import 'package:frontend_calculator/views/pages/offer_search_page.dart';
import 'package:frontend_calculator/views/pages/profil_page.dart';
import 'package:frontend_calculator/views/pages/rules_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_calculator/data/notifiers.dart';

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
              children: [_buildWelcomeHeader(context), const SizedBox(height: 24), _buildQuickActions(context)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Witaj w Evergy!',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => ProfilePage(userData: ProfilePage.getDefaultProfile())));
              },
              icon: const Icon(Icons.account_circle, size: 32),
            ),
          ],
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
              icon: Icons.calculate,
              title: 'Kalkulator',
              color: Colors.blue,
              onTap: () => selectedPageNotifier.value = 1,
            ),
            _buildActionCard(
              icon: Icons.book,
              title: 'Słownik',
              color: Colors.purple.shade100,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DictionaryPage())),
            ),
            _buildActionCard(
              icon: Icons.devices,
              title: 'Urządzenia pomiarowe',
              color: Colors.red.shade300,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MeasurementsPage())),
            ),
            _buildActionCard(
              icon: Icons.shopping_bag,
              title: 'Oferta',
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OfferSearchPage())),
            ),
            _buildActionCard(
              icon: Icons.home,
              title: 'Smart Home',
              color: Colors.green.shade200,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LocationPage())),
            ),
            _buildActionCard(
              icon: Icons.list,
              title: 'Zasady',
              color: Colors.purple.shade400,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RulesPage())),
            ),
            _buildActionCard(
              icon: Icons.alarm,
              title: 'Alarmy',
              color: Colors.yellow.shade600,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AlarmPage())),
            ),
            // _buildActionCard(
            //   icon: Icons.history,
            //   title: 'Historia',
            //   color: Colors.green,
            //   onTap: () => _showNotImplemented(context, 'Historia kalkulacji'),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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

  void _showNotImplemented(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label - funkcjonalność w trakcie implementacji')));
  }
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

