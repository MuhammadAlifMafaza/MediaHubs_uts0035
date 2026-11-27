import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'media_item.dart';
import 'media_repository.dart';

/// Firestore metadata is isolated under the current anonymous user's UID.
class FirestoreMediaRepository implements MediaRepository {
  FirestoreMediaRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  Future<User>? _signInFuture;

  Future<User> _currentUser() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) return Future.value(currentUser);

    return _signInFuture ??= _auth
        .signInAnonymously()
        .then((credential) {
          final user = credential.user;
          if (user == null) {
            throw StateError('Anonymous sign-in did not return a user.');
          }
          return user;
        })
        .whenComplete(() => _signInFuture = null);
  }

  Future<CollectionReference<Map<String, dynamic>>> _mediaCollection() async {
    final user = await _currentUser();
    return _firestore.collection('users').doc(user.uid).collection('media');
  }

  @override
  Stream<List<MediaItem>> watchItems() =>
      Stream.fromFuture(_mediaCollection()).asyncExpand(
        (collection) => collection
            .orderBy('updatedAt', descending: true)
            .snapshots()
            .map(
              (snapshot) => snapshot.docs
                  .map(MediaItem.fromFirestore)
                  .toList(growable: false),
            ),
      );

  @override
  Future<void> create(MediaItem item) async {
    final collection = await _mediaCollection();
    final data = item.toMap()
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await collection.add(data);
  }

  @override
  Future<void> update(MediaItem item) async {
    final collection = await _mediaCollection();
    final data = item.toMap()
      ..remove('createdAt')
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await collection.doc(item.id).update(data);
  }

  @override
  Future<void> delete(String documentId) async {
    final collection = await _mediaCollection();
    await collection.doc(documentId).delete();
  }
}
