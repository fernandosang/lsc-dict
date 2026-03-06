import 'package:flutter/cupertino.dart';
import 'package:lsc_dict/widgets/topic_row_card.dart';

class TemasScreen extends StatelessWidget {
  const TemasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Later you’ll replace this with data from JSON
    final topics = <_Topic>[
      _Topic(
        'Familia',
        CupertinoIcons.person_2,
        'assets/images/categories.png',
      ),
      _Topic('Números', CupertinoIcons.number, 'assets/images/categories.png'),
      _Topic(
        'Colores',
        CupertinoIcons.paintbrush,
        'assets/images/categories.png',
      ),
      _Topic('Emociones', CupertinoIcons.heart, 'assets/images/categories.png'),
      _Topic('Comida', CupertinoIcons.cart, 'assets/images/categories.png'),
      _Topic(
        'Saludos',
        CupertinoIcons.hand_raised,
        'assets/images/categories.png',
      ),
      _Topic('Tiempo', CupertinoIcons.clock, 'assets/images/categories.png'),
      _Topic('Lugares', CupertinoIcons.map, 'assets/images/categories.png'),
    ];

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Temas'),
        border: null,
      ),
      child: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 240, 244, 252),
                Color.fromARGB(255, 224, 231, 252),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explorar por temas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Elige una categoría para ver las señas disponibles.',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search (optional placeholder)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                        width: 0.7,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 14,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          CupertinoIcons.search,
                          size: 18,
                          color: CupertinoColors.systemGrey,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Buscar tema (próximamente)',
                          style: TextStyle(
                            fontSize: 15,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Column(
                    children: [
                      for (final t in topics) ...[
                        TopicRowCard(
                          title: t.title,
                          icon: t.icon,
                          assetPath: t.assetPath,
                          onTap: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (_) => CupertinoAlertDialog(
                                title: Text(t.title),
                                content: const Text(
                                  'Pantalla de tema (próximamente).',
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Topic {
  final String title;
  final IconData icon;
  final String assetPath;
  const _Topic(this.title, this.icon, this.assetPath);
}