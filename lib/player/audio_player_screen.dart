import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../media/media_item.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({
    super.key,
    this.item,
    this.networkUrl,
    this.networkTitle,
  }) : assert(item != null || networkUrl != null);

  final MediaItem? item;
  final String? networkUrl;
  final String? networkTitle;

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
    final title = widget.item?.title ?? widget.networkTitle ?? 'Network audio';
    final sourceLabel =
        widget.networkUrl != null ||
            widget.item?.sourceType == MediaSourceType.network
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
            if (widget.item != null)
              Text(
                widget.item!.creator,
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

class NetworkAudioForm extends StatefulWidget {
  const NetworkAudioForm({super.key});

  @override
  State<NetworkAudioForm> createState() => _NetworkAudioFormState();
}

class _NetworkAudioFormState extends State<NetworkAudioForm> {
  final _controller = TextEditingController();
  final _titleController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
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
        builder: (_) => AudioPlayerScreen(
          networkUrl: uri.toString(),
          networkTitle: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Network audio')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Card(
          child: ListTile(
            leading: Icon(Icons.music_note),
            title: Text('Example: Hearts2Hearts - Moonride'),
            subtitle: Text(
              'Supply your own licensed direct HTTPS audio URL. '
              'A YouTube or music page URL cannot be played as an audio stream.',
            ),
          ),
        ),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Track title (optional)',
            hintText: 'Hearts2Hearts - Moonride',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: 'Direct audio URL',
            hintText: 'https://your-domain.example/moonride.mp3',
            errorText: _error,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _play,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play'),
        ),
      ],
    ),
  );
}
