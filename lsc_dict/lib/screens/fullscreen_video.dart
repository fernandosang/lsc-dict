import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FullscreenVideo extends StatefulWidget {
  final Uri videoUri;
  final String title;

  const FullscreenVideo({
    super.key,
    required this.videoUri,
    required this.title,
  });

  @override
  State<FullscreenVideo> createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<FullscreenVideo> {
  late final VideoPlayerController _c;
  late final Future<void> _init;

  @override
  void initState() {
    super.initState();

    // Hide system UI for fullscreen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _c = VideoPlayerController.networkUrl(widget.videoUri);
    _init = _c.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _c.play();
    });

    _c.setLooping(true);
  }

  @override
  void dispose() {
    _c.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggle() {
    if (!_c.value.isInitialized) return;
    setState(() {
      _c.value.isPlaying ? _c.pause() : _c.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: FutureBuilder(
              future: _init,
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator(color: Colors.white);
                }

                return GestureDetector(
                  onTap: _toggle,
                  child: AspectRatio(
                    aspectRatio: _c.value.aspectRatio,
                    child: VideoPlayer(_c),
                  ),
                );
              },
            ),
          ),

          // Close button
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
