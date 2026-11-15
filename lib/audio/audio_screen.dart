import 'package:flutter/material.dart';

import '../media/media_catalog.dart';
import '../media/media_item.dart';
import '../media/media_navigation.dart';
import '../player/audio_player_screen.dart';
import '../search/search_screen.dart';

class AudioScreen extends StatelessWidget {
  const AudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracks = demoMediaItems.where((item) => item.type == MediaType.audio);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text('Your music', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Tap a track to start your listening session.'),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.wifi_tethering),
              title: const Text('Network audio'),
              subtitle: const Text('Play a direct HTTPS audio stream'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NetworkAudioForm(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Available offline',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (final item in tracks) PlayableMediaCard(item: item),
        ],
      ),
    );
  }
}
