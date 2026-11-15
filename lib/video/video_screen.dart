import 'package:flutter/material.dart';

import '../media/media_catalog.dart';
import '../media/media_item.dart';
import '../media/media_navigation.dart';
import '../player/youtube_player_screen.dart';
import '../search/search_screen.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final videos = demoMediaItems.where((item) => item.type == MediaType.video);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video'),
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
          Text('Watch', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Offline video and YouTube in their own players.'),
          const SizedBox(height: 20),
          Text(
            'Available offline',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (final item in videos) PlayableMediaCard(item: item),
          const SizedBox(height: 20),
          Text(
            'YouTube · online',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.smart_display_outlined, size: 32),
              title: const Text('Featured YouTube video'),
              subtitle: const Text('Tap to play · URL can be changed'),
              trailing: const Icon(Icons.play_circle_filled, size: 32),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const YoutubeVideoScreen(videoId: 'chl0R8C4NJ8'),
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const YoutubeUrlScreen()),
            ),
            icon: const Icon(Icons.link),
            label: const Text('Use another YouTube URL'),
          ),
        ],
      ),
    );
  }
}
