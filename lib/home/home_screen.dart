import 'package:flutter/material.dart';

import '../media/media_catalog.dart';
import '../media/media_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.firebaseStatus,
    required this.onOpenLibrary,
  });

  final String firebaseStatus;
  final VoidCallback onOpenLibrary;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('MediaHub')),
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
            leading: const Icon(Icons.library_music_outlined),
            title: const Text('Bundled media collection'),
            subtitle: Text(
              '${demoMediaItems.where((item) => item.type == MediaType.audio).length} audio tracks and 1 video in the app',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: onOpenLibrary,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onOpenLibrary,
          icon: const Icon(Icons.library_music),
          label: const Text('Open Library'),
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
