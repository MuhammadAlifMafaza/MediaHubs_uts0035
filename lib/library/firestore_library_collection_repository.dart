import 'package:cloud_firestore/cloud_firestore.dart';

import 'library_collection.dart';
import 'library_collection_repository.dart';

class FirestoreLibraryCollectionRepository
    implements CloudLibraryCollectionRepository {
  FirestoreLibraryCollectionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(
    LibraryCollectionType type,
  ) => _firestore.collection(
    type == LibraryCollectionType.album ? 'albums' : 'playlist',
  );

  @override
  Stream<List<LibraryCollection>> watch(LibraryCollectionType type) =>
      _collection(type).snapshots().map((snapshot) {
        final collections = snapshot.docs
            .map(
              (doc) =>
                  LibraryCollection.fromFirestore(doc.id, doc.data(), type),
            )
            .toList(growable: true);
        collections.sort((a, b) {
          final aTime = a.updatedAt;
          final bTime = b.updatedAt;
          if (aTime == null) return bTime == null ? 0 : 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
        return List.unmodifiable(collections);
      });

  @override
  Future<void> save(LibraryCollection collection) async {
    if (collection.scope != LibraryCollectionScope.cloud) {
      throw ArgumentError('Only cloud collections can be saved to Firestore.');
    }
    final reference = _collection(collection.type);
    final data = <String, Object?>{
      'name': collection.name.trim(),
      'description': collection.description.trim(),
      'trackIds': collection.trackIds,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (collection.id.isEmpty) {
      data['createdAt'] = FieldValue.serverTimestamp();
      await reference.add(data);
    } else {
      await reference.doc(collection.id).set(data, SetOptions(merge: true));
    }
  }

  @override
  Future<void> delete(LibraryCollection collection) =>
      _collection(collection.type).doc(collection.id).delete();
}
