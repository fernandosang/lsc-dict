import 'package:flutter/cupertino.dart';
import 'package:lsc_dict/screens/home_screen.dart';
import 'package:lsc_dict/screens/sordos_screen.dart';

class RootTabs extends StatelessWidget {
  const RootTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.ear),
            label: 'Oyentes',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.hand_raised),
            label: 'Sordos',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) => HomeScreen());
          case 1:
            return CupertinoTabView(builder: (context) => EspanolParaSordosScreen());
          default:
            return CupertinoTabView(builder: (context) => HomeScreen());
        }
      },
    );
  }
}