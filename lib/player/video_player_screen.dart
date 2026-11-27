import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../media/media_item.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    this.sourceType = MediaSourceType.asset,
    required this.mediaUrl,
    this.title = 'Video',
    this.creator = '',
  });

  final MediaSourceType sourceType;
  final String mediaUrl;
  final String title;
  final String creator;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  String? _error;
  bool _loading = true;
  bool _fullscreen = false;
  int _loadId = 0;
  int _lastSecond = -1;
  bool _lastPlaying = false;
  bool _lastBuffering = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    final loadId = ++_loadId;
    final old = _controller;
    _controller = null;
    if (old != null) {
      old.removeListener(_onVideoUpdate);
      await old.dispose();
    }
    if (!mounted || loadId != _loadId) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final controller = switch (widget.sourceType) {
        MediaSourceType.asset => VideoPlayerController.asset(widget.mediaUrl),
        MediaSourceType.device => VideoPlayerController.contentUri(
          Uri.parse(widget.mediaUrl),
        ),
        MediaSourceType.network => VideoPlayerController.networkUrl(
          Uri.parse(widget.mediaUrl),
        ),
        MediaSourceType.youtube => throw StateError(
          'YouTube videos must use the YouTube player.',
        ),
      };
      _controller = controller;
      await controller.initialize();
      if (!mounted || loadId != _loadId) return;
      controller.addListener(_onVideoUpdate);
      setState(() => _loading = false);
    } catch (error) {
      if (mounted && loadId == _loadId) {
        setState(() {
          _loading = false;
          _error = 'Could not open ${widget.sourceType.name} video: $error';
        });
      }
    }
  }

  void _onVideoUpdate() {
    final controller = _controller;
    if (!mounted || controller == null) return;
    final error = controller.value.errorDescription;
    if (error != null && 'Video playback failed: $error' != _error) {
      setState(() => _error = 'Video playback failed: $error');
    } else if (_error == null &&
        (_lastSecond != controller.value.position.inSeconds ||
            _lastPlaying != controller.value.isPlaying ||
            _lastBuffering != controller.value.isBuffering)) {
      _lastSecond = controller.value.position.inSeconds;
      _lastPlaying = controller.value.isPlaying;
      _lastBuffering = controller.value.isBuffering;
      setState(() {});
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      if (controller.value.isPlaying) {
        await controller.pause();
      } else {
        if (controller.value.position >= controller.value.duration) {
          await controller.seekTo(Duration.zero);
        }
        await controller.play();
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Video playback failed: $error');
    }
  }

  Future<void> _toggleFullscreen() async {
    final fullscreen = !_fullscreen;
    setState(() => _fullscreen = fullscreen);
    await SystemChrome.setPreferredOrientations(
      fullscreen
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp],
    );
    await SystemChrome.setEnabledSystemUIMode(
      fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  @override
  void dispose() {
    _loadId++;
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    if (_fullscreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  String _time(Duration duration) =>
      '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: _fullscreen ? null : AppBar(title: const Text('Now Watching')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(_fullscreen ? 4 : 16),
          children: [
            if (!_loading &&
                _error == null &&
                controller != null &&
                controller.value.isInitialized) ...[
              AspectRatio(
                aspectRatio: controller.value.aspectRatio > 0
                    ? controller.value.aspectRatio
                    : 16 / 9,
                child: GestureDetector(
                  onTap: _togglePlayback,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ColoredBox(
                        color: Colors.black,
                        child: VideoPlayer(controller),
                      ),
                      if (!controller.value.isPlaying)
                        const CircleAvatar(
                          radius: 32,
                          child: Icon(Icons.play_arrow, size: 42),
                        ),
                      if (controller.value.isBuffering)
                        const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
              VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_time(controller.value.position)} / ${_time(controller.value.duration)}',
                  ),
                  Row(
                    children: [
                      IconButton.filled(
                        tooltip: controller.value.isPlaying ? 'Pause' : 'Play',
                        onPressed: _togglePlayback,
                        icon: Icon(
                          controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      ),
                      IconButton(
                        tooltip: _fullscreen
                            ? 'Exit full screen'
                            : 'Full screen',
                        onPressed: _toggleFullscreen,
                        icon: Icon(
                          _fullscreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else if (_loading)
              const SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 56),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _error ?? 'Video unavailable.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _loadVideo,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            if (!_fullscreen) ...[
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (widget.creator.isNotEmpty) Text(widget.creator),
              const SizedBox(height: 8),
              Chip(
                label: Text(switch (widget.sourceType) {
                  MediaSourceType.asset => 'Bundled video',
                  MediaSourceType.device => 'On this device',
                  MediaSourceType.network => 'Network video',
                  MediaSourceType.youtube => 'YouTube video',
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
