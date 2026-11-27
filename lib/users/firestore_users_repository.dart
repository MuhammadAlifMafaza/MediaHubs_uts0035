import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_record.dart';
import 'users_repository.dart';

/// Classroom CRUD records live in the root `users` collection.
/// Each anonymous Firebase user can only manage records they created.
class FirestoreUsersRepository implements UsersRepository {
  FirestoreUsersRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  Future<User>? _signInFuture;

  Future<User> _currentUser() {
    final user = _auth.currentUser;
    if (user != null) return Future.value(user);

    return _signInFuture ??= _auth
        .signInAnonymously()
        .then((credential) {
          final signedInUser = credential.user;
          if (signedInUser == null) {
            throw StateError('Anonymous sign-in did not return a user.');
          }
          return signedInUser;
        })
        .whenComplete(() => _signInFuture = null);
  }

  @override
  Stream<List<UserRecord>> watchUsers() =>
      Stream.fromFuture(_currentUser()).asyncExpand((user) {
        return _firestore
            .collection('users')
            .where('ownerUid', isEqualTo: user.uid)
            .snapshots()
            .map((snapshot) {
              final users = snapshot.docs
                  .map(UserRecord.fromFirestore)
                  .toList(growable: true);
              users.sort((a, b) {
                final aTime = a.updatedAt ?? a.createdAt;
                final bTime = b.updatedAt ?? b.createdAt;
                if (aTime == null) return bTime == null ? 0 : 1;
                if (bTime == null) return -1;
                return bTime.compareTo(aTime);
              });
              return List<UserRecord>.unmodifiable(users);
            });
      });

  @override
  Future<void> create(UserRecord user) async {
    final owner = await _currentUser();
    await _firestore.collection('users').add({
      'nama': user.nama.trim(),
      'email': user.email.trim(),
      'kelas': user.kelas.trim(),
      'ownerUid': owner.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> update(UserRecord user) async {
    final owner = await _currentUser();
    await _firestore.collection('users').doc(user.id).update({
      'nama': user.nama.trim(),
      'email': user.email.trim(),
      'kelas': user.kelas.trim(),
      'ownerUid': owner.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> delete(String documentId) async {
    await _currentUser();
    await _firestore.collection('users').doc(documentId).delete();
  }
}
