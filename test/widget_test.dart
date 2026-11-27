import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediahub/main.dart';
import 'package:mediahub/player/youtube_player_screen.dart';
import 'package:mediahub/media/media_catalog.dart';
import 'package:mediahub/media/media_item.dart';
import 'package:mediahub/media/device_media_repository.dart';
import 'package:mediahub/media/device_media_section.dart';
import 'package:mediahub/media/media_repository.dart';
import 'package:mediahub/library/cloud_library_screen.dart';
import 'package:mediahub/users/user_record.dart';
import 'package:mediahub/users/users_repository.dart';
import 'package:mediahub/users/users_screen.dart';

class _EmptyDeviceMediaRepository implements DeviceMediaRepository {
  const _EmptyDeviceMediaRepository();

  @override
  Future<DeviceMediaResult> load(MediaType type) async =>
      const DeviceMediaResult(items: []);
}

class _DeniedDeviceMediaRepository implements DeviceMediaRepository {
  const _DeniedDeviceMediaRepository();

  @override
  Future<DeviceMediaResult> load(MediaType type) async =>
      const DeviceMediaResult(items: [], permissionDenied: true);
}

class _MemoryMediaRepository implements MediaRepository {
  final _items = <MediaItem>[];
  final _changes = StreamController<List<MediaItem>>.broadcast(sync: true);
  var _nextId = 0;

  @override
  Stream<List<MediaItem>> watchItems() => Stream<List<MediaItem>>.multi((sink) {
    sink.add(List.unmodifiable(_items));
    final subscription = _changes.stream.listen(
      sink.add,
      onError: sink.addError,
    );
    sink.onCancel = subscription.cancel;
  });

  void _publish() => _changes.add(List.unmodifiable(_items));

  @override
  Future<void> create(MediaItem item) async {
    _items.add(
      MediaItem(
        id: 'memory-${++_nextId}',
        title: item.title,
        creator: item.creator,
        type: item.type,
        sourceType: item.sourceType,
        mediaUrl: item.mediaUrl,
        description: item.description,
        category: item.category,
        thumbnailUrl: item.thumbnailUrl,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      ),
    );
    _publish();
  }

  @override
  Future<void> update(MediaItem item) async {
    final index = _items.indexWhere((existing) => existing.id == item.id);
    if (index < 0) throw StateError('Media not found.');
    _items[index] = item;
    _publish();
  }

  @override
  Future<void> delete(String documentId) async {
    _items.removeWhere((item) => item.id == documentId);
    _publish();
  }

  Future<void> dispose() => _changes.close();
}

class _MemoryUsersRepository implements UsersRepository {
  final _users = <UserRecord>[];
  final _changes = StreamController<List<UserRecord>>.broadcast(sync: true);
  var _nextId = 0;

  @override
  Stream<List<UserRecord>> watchUsers() =>
      Stream<List<UserRecord>>.multi((sink) {
        sink.add(List.unmodifiable(_users));
        final subscription = _changes.stream.listen(
          sink.add,
          onError: sink.addError,
        );
        sink.onCancel = subscription.cancel;
      });

  void _publish() => _changes.add(List.unmodifiable(_users));

  @override
  Future<void> create(UserRecord user) async {
    _users.add(
      UserRecord(
        id: 'user-${++_nextId}',
        nama: user.nama,
        email: user.email,
        kelas: user.kelas,
      ),
    );
    _publish();
  }

  @override
  Future<void> update(UserRecord user) async {
    final index = _users.indexWhere((existing) => existing.id == user.id);
    if (index < 0) throw StateError('User not found.');
    _users[index] = user;
    _publish();
  }

  @override
  Future<void> delete(String documentId) async {
    _users.removeWhere((user) => user.id == documentId);
    _publish();
  }

  Future<void> dispose() => _changes.close();
}

void main() {
  testWidgets('Cloud library creates, edits, and confirms media deletion', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _MemoryMediaRepository();
    await tester.pumpWidget(
      MaterialApp(home: CloudLibraryScreen(repository: repository)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your cloud library is empty.'), findsOneWidget);

    await tester.tap(find.text('Add first media'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Demo Track');
    await tester.enterText(find.byType(TextFormField).at(1), 'Demo Artist');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'https://example.org/demo.mp3',
    );
    await tester.tap(find.text('Save media'));
    await tester.pumpAndSettle();
    expect(find.text('Demo Track'), findsOneWidget);

    await tester.tap(find.byTooltip('More options for Demo Track'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Edit metadata'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit metadata'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Updated Track');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Updated Track'), findsOneWidget);

    await tester.tap(find.byTooltip('More options for Updated Track'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Delete from cloud'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Delete from cloud'));
    await tester.pumpAndSettle();
    expect(
      find.text('Delete "Updated Track" from your cloud library?'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Your cloud library is empty.'), findsOneWidget);

    await repository.dispose();
  });

  testWidgets('Users CRUD is separate and supports create, edit, delete', (
    tester,
  ) async {
    final repository = _MemoryUsersRepository();
    await tester.pumpWidget(
      MaterialApp(home: UsersScreen(repository: repository)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum ada data user.'), findsOneWidget);
    expect(
      find.text(
        'Database ini digunakan bersama tanpa login; klien lain dapat mengubah datanya.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Tambah user pertama'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Demo User');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'demo@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'SI-1');
    await tester.tap(find.text('Simpan user'));
    await tester.pumpAndSettle();
    expect(find.text('Demo User'), findsOneWidget);

    await tester.tap(find.byTooltip('Aksi untuk Demo User'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Updated User');
    await tester.tap(find.text('Simpan perubahan'));
    await tester.pumpAndSettle();
    expect(find.text('Updated User'), findsOneWidget);

    await tester.tap(find.byTooltip('Aksi untuk Updated User'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('Hapus data Updated User?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada data user.'), findsOneWidget);

    await repository.dispose();
  });

  testWidgets('Home presents MediaHub and cloud setup status', (tester) async {
    await tester.pumpWidget(
      MediaHubApp(
        firebaseInitialization: Future.value('Firebase test status.'),
        deviceMedia: const _EmptyDeviceMediaRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MediaHub'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Open Library'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Open Library'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Firestore setup status'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Firestore setup status'), findsOneWidget);
  });

  testWidgets('Audio and Video have separate destinations', (tester) async {
    await tester.pumpWidget(
      MediaHubApp(
        firebaseInitialization: Future.value('Firebase test status.'),
        deviceMedia: const _EmptyDeviceMediaRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();

    expect(find.text('Lemon Tang'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('On this device'),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('On this device'), findsOneWidget);
    expect(find.text('Network audio'), findsNothing);
    await tester.tap(find.text('Video'));
    await tester.pumpAndSettle();
    expect(find.text('Hearts2Hearts 하츠투하츠 RUDE! MV'), findsOneWidget);
    expect(find.text('Featured YouTube video'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('YouTube · online')).dy,
      lessThan(tester.getTopLeft(find.text('Available offline')).dy),
    );
  });

  testWidgets('Profile contains creator details', (tester) async {
    await tester.pumpWidget(
      MediaHubApp(
        firebaseInitialization: Future.value('Firebase test status.'),
        deviceMedia: const _EmptyDeviceMediaRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Muhammad Alif Mafaza'), findsOneWidget);
    expect(find.text('23.230.0035'), findsOneWidget);
    expect(find.text('Sistem Informasi (Bisnis Digital)'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byTooltip('GitHub'),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byTooltip('GitHub'), findsOneWidget);
    expect(find.byTooltip('Instagram'), findsOneWidget);
    expect(find.byTooltip('LinkedIn'), findsOneWidget);
  });

  testWidgets('Cloud Library shows setup gate without Firestore access', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaHubApp(
        firebaseInitialization: Future.value('Firebase test status.'),
        deviceMedia: const _EmptyDeviceMediaRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cloud Library'));
    await tester.pumpAndSettle();
    expect(find.text('Cloud catalogue is not connected'), findsOneWidget);
    expect(find.text('Firestore setup required'), findsOneWidget);
  });

  testWidgets('YouTube entry rejects a non-YouTube URL', (tester) async {
    await tester.pumpWidget(
      MediaHubApp(
        firebaseInitialization: Future.value('Firebase test status.'),
        deviceMedia: const _EmptyDeviceMediaRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Video'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use another YouTube URL'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      featuredYoutubeUrl,
    );
    await tester.enterText(
      find.byType(EditableText),
      'https://example.com/sample.mp4',
    );
    await tester.tap(find.text('Open player'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid HTTPS YouTube video URL.'), findsOneWidget);
  });

  testWidgets('Denied device media access is explained', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DeviceMediaSection(
            type: MediaType.audio,
            repository: _DeniedDeviceMediaRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Media access not granted'), findsOneWidget);
  });

  test('Bundled video catalogue references its local asset', () {
    final video = demoMediaItems.singleWhere(
      (item) => item.type == MediaType.video,
    );
    expect(video.mediaUrl, 'assets/video/rude_mv.mp4');
    expect(File(video.mediaUrl).existsSync(), isTrue);
  });
}
