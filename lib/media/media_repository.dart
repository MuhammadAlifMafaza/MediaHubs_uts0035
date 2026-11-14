import 'media_item.dart';

/// Contract for a protected, per-user cloud catalogue. No implementation is
/// registered until the Firebase collection path, Auth and Rules are approved.
/// Metadata only; asset binaries are never uploaded by this interface.
abstract interface class MediaRepository {
  Stream<List<MediaItem>> watchItems();

  Future<void> create(MediaItem item);

  Future<void> update(MediaItem item);

  Future<void> delete(String documentId);
}
