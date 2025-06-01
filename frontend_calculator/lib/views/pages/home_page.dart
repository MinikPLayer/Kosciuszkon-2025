import 'package:flutter/material.dart';
import 'package:frontend_calculator/views/pages/profil_page.dart';
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
                final userData = {
                  'email': 'example@email.com',
                  'userType': 'Osoba prywatna',
                  'voivodeship': 'Mazowieckie',
                  'buildingType': 'Dom jednorodzinny',
                  'orientation': 'Południe',
                  'roofType': 'Dachówka ceramiczna',
                  'roofAngle': 30.0,
                  'storageCapacity': '10',
                  'storageYears': '2',
                };
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage(userData: userData)));
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
              onTap: () => selectedPageNotifier.value = 2,
            ),
            _buildActionCard(
              icon: Icons.analytics,
              title: 'Analizy',
              color: Colors.red.shade300,
              onTap: () => selectedPageNotifier.value = 3,
            ),
            _buildActionCard(
              icon: Icons.shopping_bag,
              title: 'Oferta',
              color: Colors.orange,
              onTap: () => selectedPageNotifier.value = 4,
            ),
            _buildActionCard(
              icon: Icons.home,
              title: 'SmartHome',
              color: Colors.green.shade200,
              onTap: () => selectedPageNotifier.value = 5,
            ),
            _buildActionCard(
              icon: Icons.list,
              title: 'Zasady',
              color: Colors.purple.shade400,
              onTap: () => selectedPageNotifier.value = 6,
            ),
            _buildActionCard(
              icon: Icons.alarm,
              title: 'Alarmy',
              color: Colors.yellow.shade600,
              onTap: () => selectedPageNotifier.value = 7,
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

