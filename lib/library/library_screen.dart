import 'package:flutter/material.dart';

import 'cloud_library_screen.dart';
import '../media/media_catalog.dart';
import '../media/media_navigation.dart';
import '../media/media_repository.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key, this.repository});

  final MediaRepository? repository;

  void _openCloudSetup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CloudLibraryScreen(repository: repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Library')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _openCloudSetup(context),
      icon: const Icon(Icons.cloud_outlined),
      label: const Text('Cloud setup'),
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
            onTap: () => _openCloudSetup(context),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Your collection'),
            subtitle: Text(
              'Bundled app media is available below. Cloud changes remain disabled until Firestore security is approved.',
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Bundled media', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final item in demoMediaItems) PlayableMediaCard(item: item),
      ],
    ),
  );
}
