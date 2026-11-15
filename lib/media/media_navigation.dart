import 'package:flutter/material.dart';

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
        '${item.creator} · ${item.sourceType == MediaSourceType.asset ? 'Offline' : 'Network'}',
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

void openMediaPlayer(BuildContext context, MediaItem item) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => item.type == MediaType.audio
          ? AudioPlayerScreen(item: item)
          : VideoPlayerScreen(
              sourceType: item.sourceType,
              mediaUrl: item.mediaUrl,
              title: item.title,
              creator: item.creator,
            ),
    ),
  );
}
