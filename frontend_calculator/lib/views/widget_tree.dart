import 'package:flutter/material.dart';
import 'package:frontend_calculator/views/pages/alarm_page.dart';
import 'package:frontend_calculator/views/pages/location_page.dart';
import 'package:frontend_calculator/views/pages/measurements_page.dart';
import 'package:frontend_calculator/views/pages/offer_search_page.dart';
import 'package:frontend_calculator/views/pages/calculator_page.dart';
import 'package:frontend_calculator/views/pages/chatbot_page.dart';
import 'package:frontend_calculator/views/pages/dictionary_page.dart';
import 'package:frontend_calculator/views/pages/home_page.dart';
import 'package:frontend_calculator/views/pages/profil_page.dart';
import 'package:frontend_calculator/views/pages/rules_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/notifiers.dart';
import 'widgets/navbar_widget.dart';

List<Widget> pages = [const HomePage(), const CalculatorPage(), ProfilePage(userData: ProfilePage.getDefaultProfile())];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   leading: ValueListenableBuilder<int>(
        //     valueListenable: selectedPageNotifier,
        //     builder: (context, selectedPage, child) {
        //       return selectedPage != 0
        //           ? IconButton(
        //             icon: Icon(Icons.arrow_back, color: Colors.black),
        //             onPressed: () {
        //               selectedPageNotifier.value = 0; // wróć do HomePage
        //             },
        //             tooltip: 'Powrót',
        //           )
        //           : SizedBox.shrink(); // brak przycisku, jeśli jesteś na HomePage
        //     },
        //   ),
        //   title: Text(
        //     'Evergy',
        //     style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.lightGreenAccent),
        //   ),
        //   centerTitle: true,
        //   flexibleSpace: Container(
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        //         begin: Alignment.topLeft,
        //         end: Alignment.bottomRight,
        //       ),
        //     ),
        //   ),
        //   elevation: 6,
        //   actions: [
        //     IconButton(
        //       icon: Icon(Icons.person, color: Colors.black, size: 28),
        //       onPressed: () async {
        //         final userData = {
        //           'email': 'example@email.com',
        //           'userType': 'Osoba prywatna',
        //           'voivodeship': 'Mazowieckie',
        //           'buildingType': 'Dom jednorodzinny',
        //           'orientation': 'Południe',
        //           'roofType': 'Dachówka ceramiczna',
        //           'roofAngle': 30.0,
        //           'storageCapacity': '10',
        //           'storageYears': '2',
        //         };

        //         Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userData: userData)));
        //       },
        //       tooltip: 'Profil',
        //     ),
        //   ],
        // ),
        body: ValueListenableBuilder<int>(
          valueListenable: selectedPageNotifier,
          builder: (context, selectedPage, child) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: ConstrainedBox(
                key: ValueKey<int>(selectedPage),
                constraints: BoxConstraints(),
                child: Center(child: pages.elementAt(selectedPage)),
              ),
            );
          },
        ),
        bottomNavigationBar: const NavbarWidget(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          child: const Icon(Icons.chat, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatbotPage()));
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
