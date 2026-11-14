import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'youtube_video_id.dart';

class YoutubeUrlScreen extends StatefulWidget {
  const YoutubeUrlScreen({super.key});

  @override
  State<YoutubeUrlScreen> createState() => _YoutubeUrlScreenState();
}

class _YoutubeUrlScreenState extends State<YoutubeUrlScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _openVideo() {
    if (!_formKey.currentState!.validate()) return;
    final videoId = youtubeVideoId(_urlController.text)!;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => YoutubeVideoScreen(videoId: videoId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('YouTube')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Card(
          child: ListTile(
            leading: Icon(Icons.play_circle_outline),
            title: Text('Play YouTube video'),
            subtitle: Text(
              'Paste a YouTube HTTPS link. Playback requires internet; some videos disallow embedding.',
            ),
          ),
        ),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'YouTube URL',
              hintText: 'https://www.youtube.com/watch?v=...',
            ),
            validator: (value) => youtubeVideoId(value ?? '') == null
                ? 'Enter a valid HTTPS YouTube video URL.'
                : null,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _openVideo,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Open player'),
        ),
      ],
    ),
  );
}

class YoutubeVideoScreen extends StatefulWidget {
  const YoutubeVideoScreen({super.key, required this.videoId});

  final String videoId;

  @override
  State<YoutubeVideoScreen> createState() => _YoutubeVideoScreenState();
}

class _YoutubeVideoScreenState extends State<YoutubeVideoScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('YouTube player')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        YoutubePlayer(controller: _controller),
        const SizedBox(height: 12),
        const Text(
          'Playback requires internet and permission to embed the video.',
        ),
      ],
    ),
  );
}
