import 'package:flutter/cupertino.dart';

class NavCard extends StatelessWidget {
  final String title;
  final String assetPath;
  final VoidCallback onTap;

  const NavCard({
    super.key,
    required this.title,
    required this.assetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [

              /// BACKGROUND IMAGE (fills card)
              Positioned.fill(
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                ),
              ),

              /// GRADIENT OVERLAY (makes text readable)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0x00000000),
                        const Color(0x66000000),
                        const Color(0xAA000000),
                      ],
                      stops: const [0.4, 0.75, 1],
                    ),
                  ),
                ),
              ),

              /// TITLE TEXT
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: CupertinoColors.white,
                    letterSpacing: 0.2,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Color(0xAA000000),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}