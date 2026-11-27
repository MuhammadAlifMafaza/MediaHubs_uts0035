import 'package:flutter/material.dart';

import 'user_record.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key, this.initialUser, required this.onSave});

  final UserRecord? initialUser;
  final Future<void> Function(UserRecord user) onSave;

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _emailController;
  late final TextEditingController _kelasController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(
      text: widget.initialUser?.nama ?? '',
    );
    _emailController = TextEditingController(
      text: widget.initialUser?.email ?? '',
    );
    _kelasController = TextEditingController(
      text: widget.initialUser?.kelas ?? '',
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _kelasController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final user = UserRecord(
      id: widget.initialUser?.id ?? '',
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      kelas: _kelasController.text.trim(),
      createdAt: widget.initialUser?.createdAt,
      updatedAt: DateTime.now(),
    );
    try {
      await widget.onSave(user);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initialUser != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit data user' : 'Tambah user')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _namaController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nama *'),
              validator: (value) =>
                  (value?.trim().isEmpty ?? true) ? 'Nama wajib diisi.' : null,
            ),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Email *'),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Email wajib diisi.';
                if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                  return 'Masukkan alamat email yang valid.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _kelasController,
              decoration: const InputDecoration(labelText: 'Kelas *'),
              validator: (value) =>
                  (value?.trim().isEmpty ?? true) ? 'Kelas wajib diisi.' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(editing ? 'Simpan perubahan' : 'Simpan user'),
            ),
          ],
        ),
      ),
    );
  }
}
