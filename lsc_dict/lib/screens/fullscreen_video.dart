import 'package:flutter/cupertino.dart';
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

    // optional: hide system UI for real fullscreen
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
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        children: [
          Center(
            child: FutureBuilder(
              future: _init,
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const CupertinoActivityIndicator();
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
            child: Align(
              alignment: Alignment.topLeft,
              child: CupertinoButton(
                padding: const EdgeInsets.all(14),
                onPressed: () => Navigator.pop(context),
                child: const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: CupertinoColors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}