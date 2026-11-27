import 'media_item.dart';

/// Contract for a protected, per-user cloud catalogue.
/// Metadata only; media binaries are never uploaded through this interface.
abstract interface class MediaRepository {
  Stream<List<MediaItem>> watchItems();

  Future<void> create(MediaItem item);

  Future<void> update(MediaItem item);

  Future<void> delete(String documentId);
}
