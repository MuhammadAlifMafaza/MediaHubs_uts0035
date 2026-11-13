import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../media/media_item.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    this.sourceType = MediaSourceType.asset,
    required this.mediaUrl,
  });

  final MediaSourceType sourceType;
  final String mediaUrl;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final VideoPlayerController _controller;
  String? _error;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.sourceType == MediaSourceType.asset
        ? VideoPlayerController.asset(widget.mediaUrl)
        : VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl));
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      _controller.addListener(_onVideoUpdate);
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = widget.sourceType == MediaSourceType.asset
              ? 'Video unavailable. Add a compatible MP4 at ${widget.mediaUrl}.'
              : 'Could not load video from the supplied URL.';
        });
      }
    }
  }

  void _onVideoUpdate() {
    if (!mounted || _isPlaying == _controller.value.isPlaying) return;
    setState(() => _isPlaying = _controller.value.isPlaying);
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Video Player')),
    body: Center(
      child: _error != null
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_error!, textAlign: TextAlign.center),
            )
          : !_controller.value.isInitialized
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                IconButton.filled(
                  onPressed: () =>
                      _isPlaying ? _controller.pause() : _controller.play(),
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                ),
              ],
            ),
    ),
  );
}
