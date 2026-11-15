import 'package:flutter/material.dart';

import '../media/media_catalog.dart';
import '../media/device_media_repository.dart';
import '../media/device_media_section.dart';
import '../media/media_item.dart';
import '../media/media_navigation.dart';
import '../search/search_screen.dart';

class AudioScreen extends StatelessWidget {
  const AudioScreen({
    super.key,
    required this.deviceMedia,
    this.scanDevice = true,
  });

  final DeviceMediaRepository deviceMedia;
  final bool scanDevice;

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
          Text(
            'Available offline',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (final item in tracks) PlayableMediaCard(item: item),
          const SizedBox(height: 20),
          if (scanDevice)
            DeviceMediaSection(type: MediaType.audio, repository: deviceMedia),
        ],
      ),
    );
  }
}
