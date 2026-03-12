import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:lsc_dict/screens/fullscreen_video.dart';

class EntryView extends StatefulWidget {
  final String id;
  const EntryView({super.key, required this.id});

  @override
  State<EntryView> createState() => _EntryViewState();
}

class _EntryViewState extends State<EntryView> {
  late VideoPlayerController controller;
  late Future<void> initializeVideo;
  late Future<Map<String, dynamic>?> entryFuture;

  final String baseUrl = "https://pub-64f18525121f443899d18330999f4d3d.r2.dev";

  Uri _uriFromPath(String relativePath) {
    final base = Uri.parse(baseUrl);
    final rel = relativePath.replaceAll('\\', '/');
    final relSegments = rel.split('/').where((s) => s.isNotEmpty);

    return base.replace(
      pathSegments: [
        ...base.pathSegments.where((s) => s.isNotEmpty),
        ...relSegments,
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    final id = widget.id.trim().toLowerCase();

    entryFuture = _loadEntry(id);

    initializeVideo = entryFuture.then((entry) async {
      final videoPath = (entry?['video'] ?? '') as String;
      if (videoPath.isEmpty) {
        throw Exception('Missing "video" path in entries.json for "$id"');
      }

      final uri = _uriFromPath(videoPath);
      controller = VideoPlayerController.networkUrl(uri);
      await controller.initialize();
    }).then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<Map<String, dynamic>?> _loadEntry(String id) async {
    final raw = await rootBundle.loadString('assets/data/entries.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final entry = decoded[id];
    if (entry == null) return null;
    return entry as Map<String, dynamic>;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!controller.value.isInitialized) return;
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final idLabel = widget.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(idLabel),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: Future.wait([initializeVideo, entryFuture]),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data as List<dynamic>;
          final entry = data[1] as Map<String, dynamic>?;

          if (entry == null) {
            return Center(
              child: Text('No encontré metadata para "$idLabel"'),
            );
          }

          final type = (entry['type'] ?? '') as String;
          final definition = (entry['definition'] ?? '') as String;

          final example = (entry['example'] ?? {}) as Map<String, dynamic>;
          final exampleSigns = (example['signs'] ?? '') as String;
          final exampleEs = (example['es'] ?? '') as String;

          final variations = (entry['variaciones'] ?? []) as List<dynamic>;
          final variationLabels = variations.map((e) => e.toString()).toList();

          final alternatives = (entry['alternatives'] ?? []) as List<dynamic>;
          final altItems = alternatives.whereType<Map>().map((m) {
            return {
              'video': m['video'].toString(),
              'label': (m['label'] ?? 'Forma').toString(),
            };
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SquareVideoCard(
                    controller: controller,
                    onTap: _togglePlay,
                  ),
                ),

                const SizedBox(height: 18),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _InfoCard(
                    wordType: type,
                    shortDef: definition,
                    exampleSigns: exampleSigns,
                    exampleSpanish: exampleEs,
                  ),
                ),

                if (variationLabels.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _VariationsCard(items: variationLabels),
                  ),
                ],

                if (altItems.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Formas alternativas',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        for (final alt in altItems) ...[
                          _AlternativeRow(
                            baseUrl: baseUrl,
                            videoPath: alt['video']!,
                            label: alt['label']!,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SquareVideoCard extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onTap;

  const _SquareVideoCard({
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            color: Colors.black,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
                if (!controller.value.isPlaying)
                  Container(
                    color: const Color(0x22000000),
                    child: const Icon(
                      Icons.play_circle_fill,
                      size: 72,
                      color: Colors.white,
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

class _InfoCard extends StatelessWidget {
  final String wordType;
  final String shortDef;
  final String exampleSigns;
  final String exampleSpanish;

  const _InfoCard({
    required this.wordType,
    required this.shortDef,
    required this.exampleSigns,
    required this.exampleSpanish,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0x22000000), width: 0.7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wordType,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              shortDef,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Ejemplo',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade400, width: 0.7),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exampleSigns,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exampleSpanish,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariationsCard extends StatelessWidget {
  final List<String> items;

  const _VariationsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0x22000000), width: 0.7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Otros significados',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in items)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 0.7,
                      ),
                    ),
                    child: Text(
                      t,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlternativeRow extends StatefulWidget {
  final String baseUrl;
  final String videoPath;
  final String label;

  const _AlternativeRow({
    required this.baseUrl,
    required this.videoPath,
    required this.label,
  });

  @override
  State<_AlternativeRow> createState() => _AlternativeRowState();
}

class _AlternativeRowState extends State<_AlternativeRow> {
  late final VideoPlayerController _thumb;
  late final Future<void> _init;

  Uri _buildUriFromPath(String relativePath) {
    final base = Uri.parse(widget.baseUrl);
    final rel = relativePath.replaceAll('\\', '/');
    final relSegments = rel.split('/').where((s) => s.isNotEmpty);

    return base.replace(
      pathSegments: [
        ...base.pathSegments.where((s) => s.isNotEmpty),
        ...relSegments,
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    final uri = _buildUriFromPath(widget.videoPath);
    _thumb = VideoPlayerController.networkUrl(uri);
    _init = _thumb.initialize();
    _thumb.setLooping(true);
    _thumb.setVolume(0);
  }

  @override
  void dispose() {
    _thumb.dispose();
    super.dispose();
  }

  void _openFullscreen() {
    final uri = _buildUriFromPath(widget.videoPath);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenVideo(videoUri: uri, title: widget.label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openFullscreen,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0x22000000), width: 0.7),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 76,
                  height: 76,
                  color: Colors.black,
                  child: FutureBuilder(
                    future: _init,
                    builder: (_, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _thumb.value.size.width,
                              height: _thumb.value.size.height,
                              child: VideoPlayer(_thumb),
                            ),
                          ),
                          const Icon(
                            Icons.play_circle_fill,
                            size: 34,
                            color: Colors.white,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}