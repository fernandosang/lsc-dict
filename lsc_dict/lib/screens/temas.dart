import 'package:flutter/material.dart';
import 'package:lsc_dict/widgets/topic_row_card.dart';

class TemasScreen extends StatelessWidget {
  const TemasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = <_Topic>[
      _Topic('Familia', Icons.people, 'assets/images/categories.png'),
      _Topic('Números', Icons.pin, 'assets/images/categories.png'),
      _Topic('Colores', Icons.palette, 'assets/images/categories.png'),
      _Topic('Emociones', Icons.favorite, 'assets/images/categories.png'),
      _Topic('Comida', Icons.restaurant, 'assets/images/categories.png'),
      _Topic('Saludos', Icons.waving_hand, 'assets/images/categories.png'),
      _Topic('Tiempo', Icons.schedule, 'assets/images/categories.png'),
      _Topic('Lugares', Icons.map, 'assets/images/categories.png'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Temas'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Container(
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
          top: false,
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
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Elige una categoría para ver las señas disponibles.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Search placeholder
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.grey.shade400,
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
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 18,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Buscar tema (próximamente)',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
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
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(t.title),
                              content: const Text(
                                'Pantalla de tema (próximamente).',
                              ),
                              actions: [
                                TextButton(
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

                const SizedBox(height: 24),
              ],
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