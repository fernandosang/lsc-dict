import 'package:flutter/cupertino.dart';
import 'package:lsc_dict/screens/root_tabs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: RootTabs(),
    );
  }
}
