import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'user_form_screen.dart';
import 'user_record.dart';
import 'users_repository.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key, this.repository});

  final UsersRepository? repository;

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Stream<List<UserRecord>>? _users;

  @override
  void initState() {
    super.initState();
    _startWatching();
  }

  @override
  void didUpdateWidget(covariant UsersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) _startWatching();
  }

  void _startWatching() => _users = widget.repository?.watchUsers();

  void _retry() => setState(_startWatching);

  Future<void> _openForm({UserRecord? user}) async {
    final repository = widget.repository;
    if (repository == null) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => UserFormScreen(
          initialUser: user,
          onSave: user == null ? repository.create : repository.update,
        ),
      ),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(user == null ? 'User ditambahkan.' : 'User diperbarui.'),
      ),
    );
  }

  Future<void> _delete(UserRecord user) async {
    final repository = widget.repository;
    if (repository == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus data user?'),
        content: Text('Hapus data ${user.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await repository.delete(user.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Data user dihapus.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus data: $error')));
    }
  }

  String _errorMessage(Object error) {
    if (error is FirebaseAuthException &&
        error.code == 'operation-not-allowed') {
      return 'Anonymous Authentication belum diaktifkan di Firebase Console.';
    }
    if (error is FirebaseException && error.code == 'permission-denied') {
      return 'Firestore menolak akses. Periksa Rules untuk collection users.';
    }
    return 'Gagal memuat data users: $error';
  }

  @override
  Widget build(BuildContext context) {
    final repository = widget.repository;
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD Users')),
      floatingActionButton: repository == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Tambah user'),
            ),
      body: repository == null
          ? _setupRequired()
          : StreamBuilder<List<UserRecord>>(
              stream: _users,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _error(_errorMessage(snapshot.error!));
                }
                final users = snapshot.data ?? const <UserRecord>[];
                if (users.isEmpty) return _empty();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                  children: [
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('Latihan CRUD Firestore'),
                        subtitle: Text(
                          'Data contoh disimpan terpisah dari Library media.',
                        ),
                      ),
                    ),
                    for (final user in users)
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person_outline),
                          ),
                          title: Text(user.nama),
                          subtitle: Text('${user.email}\n${user.kelas}'),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            tooltip: 'Aksi untuk ${user.nama}',
                            onSelected: (action) {
                              if (action == 'edit') _openForm(user: user);
                              if (action == 'delete') _delete(user);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Hapus'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  Widget _setupRequired() => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Firebase belum siap. Periksa konfigurasi dan Rules Firestore.',
        textAlign: TextAlign.center,
      ),
    ),
  );

  Widget _error(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 56),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    ),
  );

  Widget _empty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 56),
          const SizedBox(height: 16),
          const Text('Belum ada data user.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            label: const Text('Tambah user pertama'),
          ),
        ],
      ),
    ),
  );
}
