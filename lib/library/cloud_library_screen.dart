import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../media/media_form_screen.dart';
import '../media/media_item.dart';
import '../media/media_navigation.dart';
import '../media/media_repository.dart';

class CloudLibraryScreen extends StatefulWidget {
  const CloudLibraryScreen({super.key, this.repository});

  final MediaRepository? repository;

  @override
  State<CloudLibraryScreen> createState() => _CloudLibraryScreenState();
}

class _CloudLibraryScreenState extends State<CloudLibraryScreen> {
  Stream<List<MediaItem>>? _items;

  @override
  void initState() {
    super.initState();
    _startWatching();
  }

  @override
  void didUpdateWidget(covariant CloudLibraryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) _startWatching();
  }

  void _startWatching() {
    _items = widget.repository?.watchItems();
  }

  void _retry() => setState(_startWatching);

  Future<void> _openForm({MediaItem? item}) async {
    final repository = widget.repository;
    if (repository == null) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => MediaFormScreen(
          initialItem: item,
          onSave: item == null ? repository.create : repository.update,
        ),
      ),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(item == null ? 'Media added.' : 'Media updated.')),
    );
  }

  String _errorMessage(Object error) {
    if (error is FirebaseAuthException &&
        error.code == 'operation-not-allowed') {
      return 'Anonymous sign-in is disabled. Enable it in Firebase Console > Authentication.';
    }
    if (error is FirebaseException && error.code == 'permission-denied') {
      return 'Firestore denied access. Check Rules for users/{uid}/media/{mediaId}.';
    }
    return 'Could not load cloud media: $error';
  }

  @override
  Widget build(BuildContext context) {
    final repository = widget.repository;
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Library')),
      floatingActionButton: repository == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add media'),
            ),
      body: repository == null
          ? _setupRequired()
          : StreamBuilder<List<MediaItem>>(
              stream: _items,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _cloudError(_errorMessage(snapshot.error!));
                }
                final items = snapshot.data ?? const <MediaItem>[];
                if (items.isEmpty) return _emptyLibrary();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                  children: [
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.cloud_done_outlined),
                        title: Text('Synced metadata'),
                        subtitle: Text(
                          'Audio and video files stay at their asset or network source.',
                        ),
                      ),
                    ),
                    for (final item in items)
                      PlayableMediaCard(item: item, repository: repository),
                  ],
                );
              },
            ),
    );
  }

  Widget _setupRequired() => ListView(
    padding: const EdgeInsets.all(20),
    children: const [
      Icon(Icons.cloud_off_outlined, size: 72),
      SizedBox(height: 16),
      Text('Cloud catalogue is not connected', textAlign: TextAlign.center),
      SizedBox(height: 16),
      Card(
        child: ListTile(
          leading: Icon(Icons.verified_user_outlined),
          title: Text('Firebase setup required'),
          subtitle: Text(
            'Initialize Firebase, enable Anonymous Authentication, and apply reviewed per-user Firestore Rules before cloud access.',
          ),
        ),
      ),
      Card(
        child: ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Bundled media is still available'),
          subtitle: Text(
            'Open Library for app assets. Cloud metadata does not download audio or video for offline use.',
          ),
        ),
      ),
    ],
  );

  Widget _cloudError(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 56),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );

  Widget _emptyLibrary() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.library_add_outlined, size: 56),
          const SizedBox(height: 16),
          const Text('Your cloud library is empty.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            label: const Text('Add first media'),
          ),
        ],
      ),
    ),
  );
}
