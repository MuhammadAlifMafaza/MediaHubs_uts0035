import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../media/media_item.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key, required this.item});

  final MediaItem item;

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late final AudioPlayer _player;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    if (mounted) setState(() => _error = null);
    try {
      if (widget.item.sourceType == MediaSourceType.network ||
          widget.item.sourceType == MediaSourceType.device) {
        await _player.setUrl(widget.item.mediaUrl);
      } else {
        await _player.setAsset(widget.item.mediaUrl);
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Unable to load audio: $error');
    }
  }

  Future<void> _togglePlayback() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }
        await _player.play();
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Playback failed: $error');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _time(Duration? duration) {
    final seconds = duration?.inSeconds ?? 0;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.item.title;
    final sourceLabel = widget.item.sourceType == MediaSourceType.device
        ? 'On this device'
        : widget.item.sourceType == MediaSourceType.network
        ? 'Network audio'
        : 'Available offline';

    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF156D92),
                      Color(0xFF1B775C),
                      Color(0xFF14202C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Image.asset(
                  'assets/images/logo/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              maxLines: 2,
            ),
            Text(
              widget.item.creator,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(sourceLabel),
            const SizedBox(height: 28),
            if (_error != null)
              Column(
                children: [
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _loadMedia,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            StreamBuilder<Duration?>(
              stream: _player.durationStream,
              builder: (context, durationSnapshot) {
                final duration = durationSnapshot.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, positionSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    final max = duration.inMilliseconds.toDouble();
                    return Column(
                      children: [
                        Slider(
                          value: max == 0
                              ? 0
                              : position.inMilliseconds.toDouble().clamp(
                                  0,
                                  max,
                                ),
                          max: max > 0 ? max : 1,
                          onChanged: max == 0
                              ? null
                              : (value) => _player.seek(
                                  Duration(milliseconds: value.round()),
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_time(position)),
                            Text(_time(duration)),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                if (_error == null &&
                    (state == null ||
                        state.processingState == ProcessingState.loading ||
                        state.processingState == ProcessingState.buffering)) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Center(
                  child: IconButton.filled(
                    tooltip: _player.playing ? 'Pause' : 'Play',
                    iconSize: 48,
                    onPressed: _error != null ? null : _togglePlayback,
                    icon: Icon(
                      _player.playing ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Center(child: Text('Listen your way · MediaHub')),
          ],
        ),
      ),
    );
  }
}
