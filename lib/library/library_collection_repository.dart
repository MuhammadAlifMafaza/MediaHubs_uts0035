import 'library_collection.dart';

abstract interface class LocalLibraryCollectionRepository {
  Future<List<LibraryCollection>> load();

  Future<void> save(LibraryCollection collection);

  Future<void> delete(String id);
}

abstract interface class CloudLibraryCollectionRepository {
  Stream<List<LibraryCollection>> watch(LibraryCollectionType type);

  Future<void> save(LibraryCollection collection);

  Future<void> delete(LibraryCollection collection);
}
