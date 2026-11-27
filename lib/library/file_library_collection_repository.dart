import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'library_collection.dart';
import 'library_collection_repository.dart';

class FileLibraryCollectionRepository
    implements LocalLibraryCollectionRepository {
  Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/mediahub_collections.json');
  }

  @override
  Future<List<LibraryCollection>> load() async {
    final file = await _file;
    if (!await file.exists()) return const [];
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map(
          (entry) =>
              LibraryCollection.fromLocalMap(Map<String, dynamic>.from(entry)),
        )
        .toList(growable: false);
  }

  @override
  Future<void> save(LibraryCollection collection) async {
    if (collection.scope != LibraryCollectionScope.device) {
      throw ArgumentError('Only device collections are saved locally.');
    }
    final collections = await load();
    final updated = [
      for (final existing in collections)
        if (existing.id != collection.id) existing,
      collection,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final file = await _file;
    await file.writeAsString(
      jsonEncode(updated.map((item) => item.toLocalMap()).toList()),
      flush: true,
    );
  }

  @override
  Future<void> delete(String id) async {
    final collections = await load();
    final file = await _file;
    await file.writeAsString(
      jsonEncode(
        collections
            .where((collection) => collection.id != id)
            .map((item) => item.toLocalMap())
            .toList(),
      ),
      flush: true,
    );
  }
}
