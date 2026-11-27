import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_record.dart';
import 'users_repository.dart';

/// Classroom CRUD records are shared in the root `users` collection.
class FirestoreUsersRepository implements UsersRepository {
  FirestoreUsersRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Stream<List<UserRecord>> watchUsers() =>
      _usersCollection.snapshots().map((snapshot) {
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

  @override
  Future<void> create(UserRecord user) async {
    await _usersCollection.add({
      'nama': user.nama.trim(),
      'email': user.email.trim(),
      'kelas': user.kelas.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> update(UserRecord user) async {
    await _usersCollection.doc(user.id).update({
      'nama': user.nama.trim(),
      'email': user.email.trim(),
      'kelas': user.kelas.trim(),
      // Remove the legacy anonymous owner field from existing documents.
      'ownerUid': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> delete(String documentId) async {
    await _usersCollection.doc(documentId).delete();
  }
}
