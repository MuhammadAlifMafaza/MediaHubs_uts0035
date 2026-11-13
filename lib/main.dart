import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const MediaHubApp());

class MediaHubApp extends StatelessWidget {
  const MediaHubApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MediaHub',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1769AA),
        secondary: const Color(0xFF25A879),
      ),
      useMaterial3: true,
    ),
    home: const HomeScreen(),
  );
}

class DemoTrack {
  const DemoTrack(this.title, this.asset);
  final String title;
  final String asset;
}

const demoTracks = [
  DemoTrack(
    'Lemon Tang',
    'assets/music/Hearts2Hearts_-_Lemon_Tang_(mp3.pm).mp3',
  ),
  DemoTrack('RUDE', 'assets/music/Hearts2Hearts_-_RUDE_(mp3.pm).mp3'),
  DemoTrack('Style', 'assets/music/Hearts2Hearts_-_Style_(mp3.pm).mp3'),
  DemoTrack('The Chase', 'assets/music/Hearts2Hearts_-_The_Chase_(mp3.pm).mp3'),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('MediaHub'),
      actions: [
        IconButton(
          tooltip: 'Library',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const LibraryScreen()),
          ),
          icon: const Icon(Icons.library_music_outlined),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(
          Icons.perm_media_outlined,
          size: 72,
          color: Color(0xFF1769AA),
        ),
        const SizedBox(height: 12),
        Text(
          'Your media, in one place',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'MediaHub is ready for your personal audio and video library.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const LibraryScreen()),
          ),
          icon: const Icon(Icons.library_music),
          label: const Text('Open Library'),
        ),
        const SizedBox(height: 20),
        const Card(
          child: ListTile(
            leading: Icon(Icons.cloud_off_outlined),
            title: Text('Cloud library not configured'),
            subtitle: Text(
              'Firestore access must be verified before enabling CRUD.',
            ),
          ),
        ),
      ],
    ),
  );
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Library')),
    body: ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Bundled audio · available offline'),
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.link)),
            title: const Text('Play network audio'),
            subtitle: const Text('Enter a direct HTTPS audio URL'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const NetworkAudioForm()),
            ),
          ),
        ),
        for (final track in demoTracks)
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.music_note)),
              title: Text(track.title),
              subtitle: const Text('Audio · App asset'),
              trailing: const Icon(Icons.play_circle_outline),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AudioPlayerScreen(track: track),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.video_library_outlined),
            title: const Text('Open asset video player'),
            subtitle: const Text(
              'Requires assets/video/sample.mp4; none is supplied yet.',
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const VideoPlayerScreen()),
            ),
          ),
        ),
      ],
    ),
  );
}

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key, this.track, this.networkUrl});
  final DemoTrack? track;
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
    _loadTrack();
  }

  Future<void> _loadTrack() async {
    try {
      if (widget.networkUrl case final url?) {
        await _player.setUrl(url);
      } else if (widget.track case final track?) {
        await _player.setAsset(track.asset);
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Unable to load audio: $error');
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Now Playing')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.album, size: 150, color: Color(0xFF1769AA)),
            const SizedBox(height: 20),
            Text(
              widget.track?.title ?? 'Network audio',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(widget.networkUrl == null ? 'Bundled audio asset' : 'Network audio'),
            const SizedBox(height: 20),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else
              StreamBuilder<Duration?>(
                stream: _player.durationStream,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
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
                  onPressed: () =>
                      _player.playing ? _player.pause() : _player.play(),
                  icon: Icon(_player.playing ? Icons.pause : Icons.play_arrow),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
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
      setState(() => _error = 'Enter a valid HTTPS URL for a direct audio stream.');
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

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final VideoPlayerController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/sample.mp4');
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Video unavailable. Add a compatible MP4 at assets/video/sample.mp4.');
      }
    }
  }

  @override
  void dispose() {
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
                        IconButton.filled(
                          onPressed: () => setState(() =>
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play()),
                          icon: Icon(_controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow),
                        ),
                      ],
                    ),
        ),
      );
}
