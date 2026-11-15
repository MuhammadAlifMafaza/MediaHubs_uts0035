import 'package:flutter/material.dart';

import 'cloud_library_screen.dart';
import '../media/media_form_screen.dart';

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
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Your collection'),
            subtitle: Text(
              'Audio and Video have their own tabs. Cloud metadata and Add media remain here until Firestore security is approved.',
            ),
          ),
        ),
      ],
    ),
  );
}
