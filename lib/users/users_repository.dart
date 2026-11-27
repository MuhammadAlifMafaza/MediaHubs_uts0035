import 'user_record.dart';

abstract interface class UsersRepository {
  Stream<List<UserRecord>> watchUsers();

  Future<void> create(UserRecord user);

  Future<void> update(UserRecord user);

  Future<void> delete(String documentId);
}
