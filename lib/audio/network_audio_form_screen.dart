import 'package:flutter/material.dart';

import '../media/media_item.dart';
import '../media/media_navigation.dart';

class NetworkAudioFormScreen extends StatefulWidget {
  const NetworkAudioFormScreen({super.key});

  @override
  State<NetworkAudioFormScreen> createState() => _NetworkAudioFormScreenState();
}

class _NetworkAudioFormScreenState extends State<NetworkAudioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _creatorController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _creatorController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value) {
    final uri = Uri.tryParse(value?.trim() ?? '');
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return 'Enter a direct HTTPS audio or stream URL.';
    }
    return null;
  }

  void _play() {
    if (!_formKey.currentState!.validate()) return;
    openMediaPlayer(
      context,
      MediaItem(
        id: 'network-audio',
        title: _titleController.text.trim(),
        creator: _creatorController.text.trim().isEmpty
            ? 'Unknown creator'
            : _creatorController.text.trim(),
        type: MediaType.audio,
        sourceType: MediaSourceType.network,
        mediaUrl: _urlController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Play network audio')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Use a direct audio URL'),
              subtitle: Text(
                'Paste an HTTPS MP3 or compatible stream URL. YouTube links are not direct audio streams.',
              ),
            ),
          ),
          TextFormField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Title *'),
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? 'Title is required.' : null,
          ),
          TextFormField(
            controller: _creatorController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Creator'),
          ),
          TextFormField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'HTTPS audio URL *'),
            validator: _validateUrl,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _play,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Open player'),
          ),
        ],
      ),
    ),
  );
}
