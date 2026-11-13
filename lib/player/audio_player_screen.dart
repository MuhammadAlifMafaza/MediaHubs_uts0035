import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../media/media_item.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key, this.item, this.networkUrl})
    : assert(item != null || networkUrl != null);

  final MediaItem? item;
  final String? networkUrl;

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
    try {
      final item = widget.item;
      final networkUrl = widget.networkUrl;
      if (networkUrl != null) {
        await _player.setUrl(networkUrl);
      } else if (item?.sourceType == MediaSourceType.network) {
        await _player.setUrl(item!.mediaUrl);
      } else if (item != null) {
        await _player.setAsset(item.mediaUrl);
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
    final title = widget.item?.title ?? 'Network audio';
    final sourceLabel =
        widget.networkUrl != null ||
            widget.item?.sourceType == MediaSourceType.network
        ? 'Network audio'
        : 'Bundled audio asset';

    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.album, size: 150, color: Color(0xFF1769AA)),
              const SizedBox(height: 20),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              Text(sourceLabel),
              const SizedBox(height: 20),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                )
              else
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
                    return const CircularProgressIndicator();
                  }
                  return IconButton.filled(
                    iconSize: 36,
                    onPressed: _togglePlayback,
                    icon: Icon(
                      _player.playing ? Icons.pause : Icons.play_arrow,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NetworkAudioForm extends StatefulWidget {
  const NetworkAudioForm({super.key});

  @override
  State<NetworkAudioForm> createState() => _NetworkAudioFormState();
}

class _NetworkAudioFormState extends State<NetworkAudioForm> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    final uri = Uri.tryParse(_controller.text.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      setState(
        () => _error = 'Enter a valid HTTPS URL for a direct audio stream.',
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AudioPlayerScreen(networkUrl: uri.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Network audio')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: 'Direct audio URL',
              hintText: 'https://example.com/audio.mp3',
              errorText: _error,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _play,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play'),
          ),
          const SizedBox(height: 12),
          const Text('A web page or video URL is not a playable audio stream.'),
        ],
      ),
    ),
  );
}
