import 'package:flutter/cupertino.dart';

class EspanolParaSordosScreen extends StatelessWidget {
  const EspanolParaSordosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Español para sordos'),
      ),
      child: SafeArea(
        child: Center(
          child: Text('Próximamente'),
        ),
      ),
    );
  }
}