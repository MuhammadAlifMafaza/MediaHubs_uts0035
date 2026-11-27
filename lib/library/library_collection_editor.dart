import 'package:flutter/material.dart';

import '../media/device_media_repository.dart';
import '../media/media_catalog.dart';
import '../media/media_item.dart';
import 'library_collection.dart';

class LibraryCollectionEditor extends StatefulWidget {
  const LibraryCollectionEditor({
    super.key,
    required this.type,
    required this.scope,
    required this.deviceMedia,
    required this.cloudTracks,
    required this.onSave,
    this.collection,
  });

  final LibraryCollectionType type;
  final LibraryCollectionScope scope;
  final DeviceMediaRepository deviceMedia;
  final List<MediaItem> cloudTracks;
  final LibraryCollection? collection;
  final Future<void> Function(LibraryCollection collection) onSave;

  @override
  State<LibraryCollectionEditor> createState() =>
      _LibraryCollectionEditorState();
}

class _LibraryCollectionEditorState extends State<LibraryCollectionEditor> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final List<MediaItem> _selected;
  List<MediaItem> _deviceItems = const [];
  bool _devicePermissionDenied = false;
  bool _loadingDevice = false;
  bool _saving = false;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.collection?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.collection?.description ?? '',
    );
    _selected = widget.scope == LibraryCollectionScope.device
        ? [...?widget.collection?.tracks]
        : [
            for (final id in widget.collection?.trackIds ?? const <String>[])
              for (final item in widget.cloudTracks)
                if (item.id == id) item,
          ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _scanDevice() async {
    setState(() => _loadingDevice = true);
    try {
      final results = await Future.wait([
        widget.deviceMedia.load(MediaType.audio),
        if (widget.type == LibraryCollectionType.playlist)
          widget.deviceMedia.load(MediaType.video),
      ]);
      if (!mounted) return;
      setState(() {
        _deviceItems = [for (final result in results) ...result.items];
        _devicePermissionDenied = results.any(
          (result) => result.permissionDenied,
        );
        _loadingDevice = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingDevice = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat media perangkat: $error')),
      );
    }
  }

  List<MediaItem> get _available {
    final items = <MediaItem>[
      if (widget.scope == LibraryCollectionScope.device) ...widget.cloudTracks,
      if (widget.scope == LibraryCollectionScope.device) ...demoMediaItems,
      if (widget.scope == LibraryCollectionScope.device) ..._deviceItems,
      if (widget.scope == LibraryCollectionScope.cloud) ...widget.cloudTracks,
    ];
    return items
        .where(
          (item) =>
              widget.type != LibraryCollectionType.album ||
              item.type == MediaType.audio,
        )
        .toList(growable: false);
  }

  Map<String, List<MediaItem>> get _groupedAvailable {
    final groups = <String, List<MediaItem>>{};
    for (final item in _available) {
      final path = item.locationPath?.trim();
      final group = switch (item.sourceType) {
        MediaSourceType.device =>
          path == null || path.isEmpty ? 'Folder tidak diketahui' : path,
        MediaSourceType.asset => 'Asset aplikasi',
        MediaSourceType.network || MediaSourceType.youtube => 'Katalog cloud',
      };
      groups.putIfAbsent(group, () => []).add(item);
    }
    final names = groups.keys.toList()..sort();
    return {for (final name in names) name: groups[name]!};
  }

  String _itemSubtitle(MediaItem item) {
    final path = item.locationPath?.trim();
    if (item.sourceType == MediaSourceType.device) {
      return '${item.creator} · ${item.type.name} · ${path?.isNotEmpty == true ? path : 'Folder tidak diketahui'}';
    }
    return '${item.creator} · ${item.type.name} · ${item.sourceType.name}';
  }

  void _toggle(MediaItem item, bool checked) {
    if (checked && _selected.length >= 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 500 track per koleksi.')),
      );
      return;
    }
    setState(() {
      _selected.removeWhere((selected) => selected.id == item.id);
      if (checked) _selected.add(item);
    });
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Nama koleksi wajib diisi.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama koleksi wajib diisi.')),
      );
      return;
    }
    setState(() {
      _nameError = null;
      _saving = true;
    });
    final collection = LibraryCollection(
      id: widget.collection?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      type: widget.type,
      scope: widget.scope,
      trackIds: widget.scope == LibraryCollectionScope.cloud
          ? _selected.map((item) => item.id).toList(growable: false)
          : const [],
      tracks: widget.scope == LibraryCollectionScope.device
          ? List.unmodifiable(_selected)
          : const [],
      updatedAt: DateTime.now(),
    );
    try {
      await widget.onSave(collection);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan koleksi: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCloud = widget.scope == LibraryCollectionScope.cloud;
    final title = widget.type == LibraryCollectionType.album
        ? 'album'
        : 'playlist';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection == null ? 'Buat $title' : 'Edit $title'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: ListTile(
              leading: Icon(
                isCloud ? Icons.cloud_outlined : Icons.phone_android,
              ),
              title: Text(
                isCloud ? 'Koleksi cloud bersama' : 'Koleksi lokal perangkat',
              ),
              subtitle: Text(
                isCloud
                    ? 'Dapat dilihat dan diubah semua client yang memiliki akses Firestore.'
                    : 'Hanya tersimpan di perangkat ini. File media tidak disalin atau diunggah.',
              ),
            ),
          ),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama koleksi *',
              errorText: _nameError,
            ),
            onChanged: (value) {
              if (_nameError != null && value.trim().isNotEmpty) {
                setState(() => _nameError = null);
              }
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Deskripsi'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Text(
            'Track (${_selected.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (_selected.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selected.length,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  final item = _selected.removeAt(oldIndex);
                  _selected.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final item = _selected[index];
                return Card(
                  key: ValueKey('selected-${item.id}'),
                  child: ListTile(
                    leading: const Icon(Icons.drag_handle),
                    title: Text('${index + 1}. ${item.title}'),
                    subtitle: Text(
                      item.locationPath?.trim().isNotEmpty == true
                          ? item.locationPath!
                          : item.creator,
                    ),
                    trailing: IconButton(
                      tooltip: 'Hapus track dari koleksi',
                      onPressed: () => _toggle(item, false),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                  ),
                );
              },
            ),
          if (!isCloud)
            OutlinedButton.icon(
              onPressed: _loadingDevice ? null : _scanDevice,
              icon: _loadingDevice
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.folder_open_outlined),
              label: Text(
                _loadingDevice
                    ? 'Memindai perangkat…'
                    : 'Pilih media dari perangkat',
              ),
            ),
          if (_devicePermissionDenied)
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Izin media belum diberikan'),
                subtitle: Text(
                  'Izinkan akses audio/video pada pengaturan Android, lalu pindai ulang.',
                ),
              ),
            ),
          if (isCloud)
            const Text(
              'Pilih track dari katalog cloud. File perangkat hanya dapat dimasukkan ke koleksi lokal.',
            ),
          if (!isCloud)
            const Text(
              'Pilih dari katalog aplikasi atau media perangkat yang tersedia.',
            ),
          const SizedBox(height: 8),
          if (_available.isEmpty)
            const Card(
              child: ListTile(
                title: Text('Belum ada track yang dapat dipilih.'),
              ),
            )
          else
            for (final group in _groupedAvailable.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 4),
                child: Text(
                  group.key,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final item in group.value)
                CheckboxListTile(
                  value: _selected.any((selected) => selected.id == item.id),
                  onChanged: (value) => _toggle(item, value ?? false),
                  title: Text(item.title),
                  subtitle: Text(_itemSubtitle(item)),
                  secondary: Icon(
                    item.type == MediaType.audio
                        ? Icons.music_note
                        : Icons.movie,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
            ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: FilledButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Menyimpan…' : 'Simpan koleksi'),
          ),
        ),
      ),
    );
  }
}
