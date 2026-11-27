import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../player/audio_player_screen.dart';
import '../player/video_player_screen.dart';
import '../player/youtube_player_screen.dart';
import '../player/youtube_video_id.dart';
import 'media_detail_screen.dart';
import 'media_item.dart';
import 'media_repository.dart';

/// Tap plays immediately; metadata remains available from the overflow menu.
class PlayableMediaCard extends StatelessWidget {
  const PlayableMediaCard({super.key, required this.item, this.repository});

  final MediaItem item;
  final MediaRepository? repository;

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
          MediaSourceType.youtube => 'YouTube',
        }}',
      ),
      onTap: () => openMediaPlayer(context, item),
      trailing: PopupMenuButton<String>(
        tooltip: 'More options for ${item.title}',
        onSelected: (_) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                MediaDetailScreen(item: item, repository: repository),
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
  if (item.sourceType == MediaSourceType.youtube) {
    final videoId = youtubeVideoId(item.mediaUrl);
    if (videoId == null || item.type != MediaType.video) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link YouTube video tidak valid.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => YoutubeVideoScreen(videoId: videoId, title: item.title),
      ),
    );
    return;
  }
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
