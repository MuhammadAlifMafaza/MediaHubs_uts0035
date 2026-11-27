import 'package:cloud_firestore/cloud_firestore.dart';

import '../media/media_item.dart';

enum LibraryCollectionType { album, playlist }

enum LibraryCollectionScope { cloud, device }

class LibraryCollection {
  const LibraryCollection({
    required this.id,
    required this.name,
    required this.type,
    required this.scope,
    this.description = '',
    this.trackIds = const [],
    this.tracks = const [],
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final LibraryCollectionType type;
  final LibraryCollectionScope scope;

  /// Firestore collection members reference documents in `songs` in display order.
  final List<String> trackIds;

  /// Device collections keep local media references and metadata on this device.
  final List<MediaItem> tracks;
  final DateTime? updatedAt;

  Map<String, Object?> toLocalMap() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.name,
    'scope': scope.name,
    'tracks': tracks.map((track) => track.toLocalMap()).toList(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory LibraryCollection.fromLocalMap(Map<String, dynamic> data) {
    final rawTracks = data['tracks'];
    final type = LibraryCollectionType.values.firstWhere(
      (value) => value.name == data['type'],
      orElse: () => LibraryCollectionType.playlist,
    );
    return LibraryCollection(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? 'Untitled collection',
      description: data['description'] as String? ?? '',
      type: type,
      scope: LibraryCollectionScope.device,
      tracks: rawTracks is List
          ? rawTracks
                .whereType<Map>()
                .map(
                  (track) =>
                      MediaItem.fromLocalMap(Map<String, dynamic>.from(track)),
                )
                .toList(growable: false)
          : const [],
      updatedAt: DateTime.tryParse(data['updatedAt'] as String? ?? ''),
    );
  }

  factory LibraryCollection.fromFirestore(
    String id,
    Map<String, dynamic> data,
    LibraryCollectionType type,
  ) => LibraryCollection(
    id: id,
    name: data['name'] as String? ?? 'Untitled collection',
    description: data['description'] as String? ?? '',
    type: type,
    scope: LibraryCollectionScope.cloud,
    trackIds: (data['trackIds'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(growable: false),
    updatedAt: switch (data['updatedAt']) {
      Timestamp timestamp => timestamp.toDate(),
      final DateTime date => date,
      _ => null,
    },
  );
}
