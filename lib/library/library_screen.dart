import 'package:flutter/material.dart';

import '../media/media_catalog.dart';
import '../media/media_detail_screen.dart';
import '../media/media_form_screen.dart';
import '../player/audio_player_screen.dart';

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
      padding: const EdgeInsets.all(12),
      children: [
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
