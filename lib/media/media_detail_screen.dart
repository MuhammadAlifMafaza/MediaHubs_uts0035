import 'package:flutter/material.dart';

import 'media_navigation.dart';
import 'media_item.dart';

class MediaDetailScreen extends StatelessWidget {
  const MediaDetailScreen({super.key, required this.item});

  final MediaItem item;

  void _play(BuildContext context) {
    openMediaPlayer(context, item);
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
