import 'package:flutter/material.dart';

class TopicRowCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String assetPath;
  final VoidCallback onTap;

  const TopicRowCard({
    super.key,
    required this.title,
    required this.icon,
    required this.assetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 120,
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.asset(assetPath, fit: BoxFit.cover),
                ),

                // Readability gradient
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xD9000000),
                          Color(0x88000000),
                          Color(0x00000000),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon, color: Colors.black, size: 22),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 12,
                                  color: Color(0xAA000000),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 18,
                        ),
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
