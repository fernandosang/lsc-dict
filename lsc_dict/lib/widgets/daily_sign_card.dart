import 'package:flutter/cupertino.dart';

class DailySignCard extends StatelessWidget {
  final VoidCallback? onTap;

  const DailySignCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 200),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color:  Color(0x22000000),
            width: 0.7,
          ),
        ),
        child: Row(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/logo.png',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(width: 16),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'La seña del día',
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Próximamente',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.label,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: CupertinoColors.systemGrey2,
            ),
          ],
        ),
      ),
    );
  }
}