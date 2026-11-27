import 'package:flutter/material.dart';

import '../media/media_catalog.dart';
import '../media/media_item.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.firebaseStatus,
    required this.onOpenLibrary,
    required this.onOpenAudio,
    required this.onOpenVideo,
    required this.onOpenUsers,
  });

  final String firebaseStatus;
  final VoidCallback onOpenLibrary;
  final VoidCallback onOpenAudio;
  final VoidCallback onOpenVideo;
  final VoidCallback onOpenUsers;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('MediaHub'),
      actions: [
        IconButton(
          tooltip: 'Search',
          icon: const Icon(Icons.search),
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const SearchScreen())),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Image.asset(
              'assets/images/logo/logo.png',
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your media, in one place',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Your personal audio and video library.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.headphones),
            title: const Text('Your music'),
            subtitle: Text(
              '${demoMediaItems.where((item) => item.type == MediaType.audio).length} offline tracks',
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: onOpenAudio,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.movie_outlined),
            title: const Text('Watch videos'),
            subtitle: const Text('Offline MP4 and YouTube'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: onOpenVideo,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onOpenLibrary,
          icon: const Icon(Icons.library_music),
          label: const Text('Open Library'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onOpenUsers,
          icon: const Icon(Icons.people_outline),
          label: const Text('CRUD Users · Firestore'),
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: Icon(
              firebaseStatus.startsWith('Firebase initialization failed:')
                  ? Icons.cloud_off_outlined
                  : Icons.cloud_queue_outlined,
            ),
            title: const Text('Cloud library not configured'),
            subtitle: Text(
              '$firebaseStatus Firestore schema, Authentication, and rules must be verified before enabling CRUD.',
            ),
          ),
        ),
      ],
    ),
  );
}
