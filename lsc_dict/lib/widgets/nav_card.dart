import 'package:flutter/material.dart';

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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
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
                /// BACKGROUND IMAGE
                Positioned.fill(
                  child: Image.asset(assetPath, fit: BoxFit.cover),
                ),

                /// GRADIENT OVERLAY
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          Color(0x66000000),
                          Color(0xAA000000),
                        ],
                        stops: [0.4, 0.75, 1],
                      ),
                    ),
                  ),
                ),

                /// TITLE
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                      shadows: [
                        Shadow(blurRadius: 10, color: Color(0xAA000000)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
