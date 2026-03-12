import 'package:flutter/material.dart';
import 'package:lsc_dict/screens/home_screen.dart';
import 'package:lsc_dict/screens/sordos_screen.dart';

class RootTabs extends StatefulWidget {
  const RootTabs({super.key});

  @override
  State<RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends State<RootTabs> {
  int _currentIndex = 0;

  final List<Widget> _pages = [HomeScreen(), EspanolParaSordosScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.hearing), label: 'Oyentes'),
          NavigationDestination(
            icon: Icon(Icons.sign_language),
            label: 'Sordos',
          ),
        ],
      ),
    );
  }
}
