import 'package:cloud_firestore/cloud_firestore.dart';

import 'media_item.dart';
import 'media_repository.dart';

/// Media metadata is shared by all clients allowed by the Firestore Rules.
class FirestoreMediaRepository implements MediaRepository {
  FirestoreMediaRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _songsCollection =>
      _firestore.collection('songs');

  @override
  Stream<List<MediaItem>> watchItems() => _songsCollection
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map(MediaItem.fromFirestore).toList(growable: false),
      );

  @override
  Future<void> create(MediaItem item) async {
    final data = item.toMap()
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await _songsCollection.add(data);
  }

  @override
  Future<void> update(MediaItem item) async {
    final data = item.toMap()
      ..remove('createdAt')
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await _songsCollection.doc(item.id).update(data);
  }

  @override
  Future<void> delete(String documentId) async {
    await _songsCollection.doc(documentId).delete();
  }
}
