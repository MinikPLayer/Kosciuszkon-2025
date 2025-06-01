import '../../../data/notifiers.dart';
import 'package:flutter/material.dart';

class NavbarWidget extends StatefulWidget {
  const NavbarWidget({super.key});

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon:
                  selectedPage == 0
                      ? const Icon(Icons.home_outlined, key: ValueKey('selected'))
                      : const Icon(Icons.home, key: ValueKey('unselected')),
              label: 'Strona główna',
            ),
            BottomNavigationBarItem(
              icon:
                  selectedPage == 1
                      ? const Icon(Icons.calculate, key: ValueKey('selected'))
                      : const Icon(Icons.calculate_outlined, key: ValueKey('unselected')),
              label: 'Kalkulator',
            ),
            BottomNavigationBarItem(
              icon:
                  selectedPage == 2
                      ? const Icon(Icons.person, key: ValueKey('selected'))
                      : const Icon(Icons.person_outline, key: ValueKey('unselected')),
              label: 'Użytkownik',
            ),
          ],
          currentIndex: selectedPage,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (selectedPage != index) {
              _controller.reset();
              _controller.forward();
              selectedPageNotifier.value = index;
            }
          },
        );
      },
    );
  }
}
