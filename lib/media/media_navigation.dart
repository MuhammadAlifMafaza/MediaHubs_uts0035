import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../player/audio_player_screen.dart';
import '../player/video_player_screen.dart';
import 'media_detail_screen.dart';
import 'media_item.dart';

/// Tap plays immediately; metadata remains available from the overflow menu.
class PlayableMediaCard extends StatelessWidget {
  const PlayableMediaCard({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 26,
        child: Icon(
          item.type == MediaType.audio ? Icons.music_note : Icons.movie,
        ),
      ),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${item.creator} · ${switch (item.sourceType) {
          MediaSourceType.asset => 'Bundled',
          MediaSourceType.device => 'Device',
          MediaSourceType.network => 'Online',
        }}',
      ),
      onTap: () => openMediaPlayer(context, item),
      trailing: PopupMenuButton<String>(
        tooltip: 'More options for ${item.title}',
        onSelected: (_) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MediaDetailScreen(item: item),
          ),
        ),
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'details', child: Text('Details')),
        ],
      ),
    ),
  );
}

Future<void> openMediaPlayer(BuildContext context, MediaItem item) async {
  var playableItem = item;
  if (item.sourceType == MediaSourceType.device) {
    try {
      final entity = await AssetEntity.fromId(item.mediaUrl);
      final uri = await entity?.getMediaUrl();
      if (uri == null || uri.isEmpty) {
        throw StateError(
          'The file is no longer available or media access was revoked.',
        );
      }
      playableItem = MediaItem(
        id: item.id,
        title: item.title,
        creator: item.creator,
        type: item.type,
        sourceType: item.sourceType,
        mediaUrl: uri,
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open device media: $error')),
        );
      }
      return;
    }
  }
  if (!context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => playableItem.type == MediaType.audio
          ? AudioPlayerScreen(item: playableItem)
          : VideoPlayerScreen(
              sourceType: playableItem.sourceType,
              mediaUrl: playableItem.mediaUrl,
              title: playableItem.title,
              creator: playableItem.creator,
            ),
    ),
  );
}
