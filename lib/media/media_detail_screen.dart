import 'package:flutter/material.dart';

import 'media_navigation.dart';
import 'media_item.dart';
import 'media_form_screen.dart';
import 'media_repository.dart';

class MediaDetailScreen extends StatelessWidget {
  const MediaDetailScreen({super.key, required this.item, this.repository});

  final MediaItem item;
  final MediaRepository? repository;

  void _play(BuildContext context) {
    openMediaPlayer(context, item);
  }

  Future<void> _edit(BuildContext context) async {
    final repository = this.repository;
    if (repository == null) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            MediaFormScreen(initialItem: item, onSave: repository.update),
      ),
    );
    if (!context.mounted || saved != true) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(content: Text('Media updated.')));
  }

  Future<void> _delete(BuildContext context) async {
    final repository = this.repository;
    if (repository == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete media?'),
        content: Text('Delete "${item.title}" from your cloud library?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await repository.delete(item.id);
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: Text('Media deleted.')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not delete media: $error')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Media details')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 64,
          child: Icon(
            item.type == MediaType.audio ? Icons.music_note : Icons.movie,
            size: 64,
          ),
        ),
        const SizedBox(height: 24),
        Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(item.creator, style: Theme.of(context).textTheme.titleMedium),
        if (item.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(item.description),
        ],
        const Divider(height: 32),
        _DetailRow(label: 'Type', value: item.type.name),
        if (item.category.isNotEmpty)
          _DetailRow(label: 'Category', value: item.category),
        _DetailRow(label: 'Source', value: item.sourceType.name),
        if (item.sourceType != MediaSourceType.device)
          _DetailRow(label: 'Media URL/path', value: item.mediaUrl),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => _play(context),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play media'),
        ),
        if (repository != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _edit(context),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit metadata'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _delete(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete from cloud'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
