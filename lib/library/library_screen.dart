import 'package:flutter/material.dart';

import 'cloud_library_screen.dart';
import '../media/media_catalog.dart';
import '../media/media_detail_screen.dart';
import '../media/media_form_screen.dart';
import '../player/audio_player_screen.dart';
import '../player/youtube_player_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  void _openAddMediaForm(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const MediaFormScreen()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Library')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _openAddMediaForm(context),
      icon: const Icon(Icons.add),
      label: const Text('Add media'),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('Cloud Library'),
            subtitle: const Text('Firestore setup pending verification'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CloudLibraryScreen(),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Bundled media · available offline'),
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
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.play_circle_outline)),
            title: const Text('Play YouTube video'),
            subtitle: const Text('Paste a YouTube video link'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const YoutubeUrlScreen()),
            ),
          ),
        ),
        for (final item in demoMediaItems)
          MediaCard(
            item: item,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MediaDetailScreen(item: item),
              ),
            ),
          ),
      ],
    ),
  );
}
