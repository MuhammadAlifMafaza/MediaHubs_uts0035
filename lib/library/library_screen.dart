import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../media/device_media_repository.dart';
import '../media/media_catalog.dart';
import '../media/media_item.dart';
import '../media/media_navigation.dart';
import '../media/media_repository.dart';
import 'cloud_library_screen.dart';
import 'file_library_collection_repository.dart';
import 'library_collection.dart';
import 'library_collection_editor.dart';
import 'library_collection_repository.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    this.repository,
    this.deviceMedia,
    this.localCollections,
    this.cloudCollections,
  });

  final MediaRepository? repository;
  final DeviceMediaRepository? deviceMedia;
  final LocalLibraryCollectionRepository? localCollections;
  final CloudLibraryCollectionRepository? cloudCollections;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final LocalLibraryCollectionRepository _localRepository;
  late final DeviceMediaRepository _deviceRepository;
  late Future<List<LibraryCollection>> _localCollectionsFuture;
  List<MediaItem> _cloudItems = const [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _localRepository =
        widget.localCollections ?? FileLibraryCollectionRepository();
    _deviceRepository =
        widget.deviceMedia ?? const PhotoManagerDeviceMediaRepository();
    _localCollectionsFuture = _localRepository.load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _refreshLocal() async {
    setState(() => _localCollectionsFuture = _localRepository.load());
  }

  Future<void> _createCollection(LibraryCollectionType type) async {
    final scope = await showModalBottomSheet<LibraryCollectionScope>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Buat ${type.name}'),
              subtitle: const Text('Pilih lokasi penyimpanan koleksi.'),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Di perangkat ini'),
              subtitle: const Text('Cocok untuk memasukkan file lokal.'),
              onTap: () =>
                  Navigator.pop(context, LibraryCollectionScope.device),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_outlined),
              title: const Text('Cloud bersama'),
              subtitle: const Text(
                'Dapat dilihat client lain dengan akses Firestore.',
              ),
              enabled:
                  widget.cloudCollections != null && widget.repository != null,
              onTap: () => Navigator.pop(context, LibraryCollectionScope.cloud),
            ),
          ],
        ),
      ),
    );
    if (scope == null || !mounted) return;
    await _openEditor(type: type, scope: scope);
  }

  Future<List<MediaItem>> _loadCloudItems() async {
    final repository = widget.repository;
    if (repository == null) return const [];
    try {
      return await repository.watchItems().first;
    } catch (_) {
      return _cloudItems;
    }
  }

  Future<void> _openEditor({
    required LibraryCollectionType type,
    required LibraryCollectionScope scope,
    LibraryCollection? collection,
  }) async {
    final available = scope == LibraryCollectionScope.cloud
        ? await _loadCloudItems()
        : _cloudItems;
    if (!mounted) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => LibraryCollectionEditor(
          type: type,
          scope: scope,
          collection: collection,
          deviceMedia: _deviceRepository,
          cloudTracks: available,
          onSave: _saveCollection,
        ),
      ),
    );
    if (saved == true) await _refreshLocal();
  }

  Future<void> _saveCollection(LibraryCollection collection) async {
    if (collection.scope == LibraryCollectionScope.device) {
      final saved = collection.id.isEmpty
          ? LibraryCollection(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              name: collection.name,
              description: collection.description,
              type: collection.type,
              scope: collection.scope,
              tracks: collection.tracks,
              updatedAt: collection.updatedAt,
            )
          : collection;
      await _localRepository.save(saved);
    } else {
      final repository = widget.cloudCollections;
      if (repository == null) {
        throw StateError('Firestore koleksi belum aktif.');
      }
      await repository.save(collection);
    }
  }

  Future<void> _deleteCollection(LibraryCollection collection) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus koleksi?'),
        content: Text('Koleksi "${collection.name}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (collection.scope == LibraryCollectionScope.device) {
      await _localRepository.delete(collection.id);
      await _refreshLocal();
    } else {
      await widget.cloudCollections?.delete(collection);
    }
  }

  Widget _tracksTab() => ListView(
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
    children: [
      Card(
        child: ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Bangun koleksi dari track'),
          subtitle: const Text(
            'Buat album audio atau playlist, lalu susun track dari katalog cloud, asset aplikasi, dan file perangkat.',
          ),
        ),
      ),
      FilledButton.tonalIcon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CloudLibraryScreen(repository: widget.repository),
          ),
        ),
        icon: const Icon(Icons.add_link),
        label: const Text('Tambah track dari URL atau asset'),
      ),
      const SizedBox(height: 16),
      Text('Media aplikasi', style: Theme.of(context).textTheme.titleLarge),
      for (final item in demoMediaItems) PlayableMediaCard(item: item),
      const SizedBox(height: 16),
      Text('Katalog cloud', style: Theme.of(context).textTheme.titleLarge),
      if (widget.repository == null)
        const Card(
          child: ListTile(
            title: Text('Firestore belum tersedia'),
            subtitle: Text(
              'Media aplikasi dan koleksi lokal tetap dapat digunakan.',
            ),
          ),
        )
      else
        StreamBuilder<List<MediaItem>>(
          stream: widget.repository!.watchItems(),
          builder: (context, snapshot) {
            if (snapshot.hasData) _cloudItems = snapshot.data!;
            if (snapshot.hasError) {
              return Card(
                child: ListTile(
                  title: Text('Katalog cloud gagal dimuat: ${snapshot.error}'),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.isEmpty) {
              return const Card(
                child: ListTile(title: Text('Belum ada track cloud.')),
              );
            }
            return Column(
              children: [
                for (final item in snapshot.data!)
                  PlayableMediaCard(item: item, repository: widget.repository),
              ],
            );
          },
        ),
    ],
  );

  Widget _collectionTab(LibraryCollectionType type) {
    final cloudStream =
        widget.cloudCollections?.watch(type) ??
        Stream<List<LibraryCollection>>.value(const []);
    return StreamBuilder<List<LibraryCollection>>(
      stream: cloudStream,
      builder: (context, cloudSnapshot) => FutureBuilder<List<LibraryCollection>>(
        future: _localCollectionsFuture,
        builder: (context, localSnapshot) {
          final cloud = cloudSnapshot.data ?? const <LibraryCollection>[];
          final local = localSnapshot.data ?? const <LibraryCollection>[];
          final localForType = local
              .where((item) => item.type == type)
              .toList();
          if (cloudSnapshot.hasError || localSnapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat koleksi: ${cloudSnapshot.error ?? localSnapshot.error}',
              ),
            );
          }
          if (!localSnapshot.hasData &&
              cloudSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            children: [
              if (type == LibraryCollectionType.album)
                const Card(
                  child: ListTile(
                    title: Text('Album berisi track audio yang tersusun.'),
                  ),
                )
              else
                const Card(
                  child: ListTile(
                    title: Text(
                      'Playlist dapat berisi track audio atau video.',
                    ),
                  ),
                ),
              if (localForType.isEmpty && cloud.isEmpty)
                const Card(
                  child: ListTile(
                    title: Text(
                      'Belum ada koleksi. Buat koleksi dan tambahkan track.',
                    ),
                  ),
                ),
              for (final collection in [...localForType, ...cloud])
                _collectionCard(collection),
            ],
          );
        },
      ),
    );
  }

  Widget _collectionCard(LibraryCollection collection) {
    final count = collection.scope == LibraryCollectionScope.device
        ? collection.tracks.length
        : collection.trackIds.length;
    return Card(
      child: ListTile(
        leading: Icon(
          collection.type == LibraryCollectionType.album
              ? Icons.album_outlined
              : Icons.queue_music_outlined,
        ),
        title: Text(collection.name),
        subtitle: Text(
          '${collection.scope == LibraryCollectionScope.device ? 'Lokal' : 'Cloud bersama'} · $count track',
        ),
        onTap: () => _showCollection(collection),
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'edit') {
              _openEditor(
                type: collection.type,
                scope: collection.scope,
                collection: collection,
              );
            } else if (action == 'delete') {
              _deleteCollection(collection);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit koleksi')),
            PopupMenuItem(value: 'delete', child: Text('Hapus koleksi')),
          ],
        ),
      ),
    );
  }

  Future<void> _showCollection(LibraryCollection collection) async {
    final cloudById = {for (final item in _cloudItems) item.id: item};
    final tracks = collection.scope == LibraryCollectionScope.device
        ? collection.tracks
        : collection.trackIds
              .map((id) => cloudById[id])
              .whereType<MediaItem>()
              .toList(growable: false);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(collection.name)),
          body: tracks.isEmpty
              ? const Center(
                  child: Text('Track tidak tersedia di katalog saat ini.'),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    if (collection.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(collection.description),
                      ),
                    if (collection.scope == LibraryCollectionScope.cloud &&
                        tracks.length < collection.trackIds.length)
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('Sebagian track tidak tersedia'),
                          subtitle: Text(
                            'Track mungkin sudah dihapus dari katalog cloud.',
                          ),
                        ),
                      ),
                    for (final item in tracks)
                      item.sourceType == MediaSourceType.device
                          ? _DeviceCollectionTrack(item: item)
                          : PlayableMediaCard(
                              item: item,
                              repository: widget.repository,
                            ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Library'),
      bottom: TabBar(
        controller: _tabs,
        tabs: const [
          Tab(text: 'Track'),
          Tab(text: 'Album'),
          Tab(text: 'Playlist'),
        ],
      ),
    ),
    floatingActionButton: AnimatedBuilder(
      animation: _tabs,
      builder: (context, _) => _tabs.index == 0
          ? const SizedBox.shrink()
          : FloatingActionButton.extended(
              onPressed: () => _createCollection(
                _tabs.index == 1
                    ? LibraryCollectionType.album
                    : LibraryCollectionType.playlist,
              ),
              icon: const Icon(Icons.add),
              label: Text(_tabs.index == 1 ? 'Buat album' : 'Buat playlist'),
            ),
    ),
    body: TabBarView(
      controller: _tabs,
      children: [
        _tracksTab(),
        _collectionTab(LibraryCollectionType.album),
        _collectionTab(LibraryCollectionType.playlist),
      ],
    ),
  );
}

class _DeviceCollectionTrack extends StatefulWidget {
  const _DeviceCollectionTrack({required this.item});

  final MediaItem item;

  @override
  State<_DeviceCollectionTrack> createState() => _DeviceCollectionTrackState();
}

class _DeviceCollectionTrackState extends State<_DeviceCollectionTrack> {
  late final Future<AssetEntity?> _asset = AssetEntity.fromId(
    widget.item.mediaUrl,
  );

  @override
  Widget build(BuildContext context) => FutureBuilder<AssetEntity?>(
    future: _asset,
    builder: (context, snapshot) {
      final unavailable =
          snapshot.connectionState == ConnectionState.done &&
          (snapshot.hasError || snapshot.data == null);
      return Card(
        child: ListTile(
          leading: Icon(
            unavailable ? Icons.cloud_off_outlined : Icons.phone_android,
          ),
          title: Text(widget.item.title),
          subtitle: Text(
            unavailable
                ? 'File tidak tersedia. Mungkin telah dipindahkan atau akses dicabut.'
                : snapshot.connectionState == ConnectionState.done
                ? '${widget.item.creator} · File di perangkat ini'
                : 'Memeriksa file perangkat…',
          ),
          onTap: unavailable || !snapshot.hasData
              ? null
              : () => openMediaPlayer(context, widget.item),
        ),
      );
    },
  );
}
