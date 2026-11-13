import 'package:flutter/material.dart';

import 'media_item.dart';

const demoMediaItems = [
  MediaItem(
    id: 'local-lemon-tang',
    title: 'Lemon Tang',
    creator: 'Hearts2Hearts',
    type: MediaType.audio,
    sourceType: MediaSourceType.asset,
    mediaUrl: 'assets/music/Hearts2Hearts_-_Lemon_Tang.mp3',
    category: 'Music',
  ),
  MediaItem(
    id: 'local-rude',
    title: 'RUDE',
    creator: 'Hearts2Hearts',
    type: MediaType.audio,
    sourceType: MediaSourceType.asset,
    mediaUrl: 'assets/music/Hearts2Hearts_-_RUDE.mp3',
    category: 'Music',
  ),
  MediaItem(
    id: 'local-style',
    title: 'Style',
    creator: 'Hearts2Hearts',
    type: MediaType.audio,
    sourceType: MediaSourceType.asset,
    mediaUrl: 'assets/music/Hearts2Hearts_-_Style.mp3',
    category: 'Music',
  ),
  MediaItem(
    id: 'local-the-chase',
    title: 'The Chase',
    creator: 'Hearts2Hearts',
    type: MediaType.audio,
    sourceType: MediaSourceType.asset,
    mediaUrl: 'assets/music/Hearts2Hearts_-_The_Chase.mp3',
    category: 'Music',
  ),
  MediaItem(
    id: 'local-focus',
    title: 'FOCUS',
    creator: 'Hearts2Hearts',
    type: MediaType.audio,
    sourceType: MediaSourceType.asset,
    mediaUrl: 'assets/music/Hearts2Hearts_-_FOCUS.mp3',
    category: 'Music',
  ),
  MediaItem(
    id: 'local-rude-video',
    title: 'RUDE! MV',
    creator: 'Hearts2Hearts',
    type: MediaType.video,
    sourceType: MediaSourceType.asset,
    mediaUrl: "assets/video/Hearts2Hearts 하츠투하츠 'RUDE!' MV.mp4",
    category: 'Music Video',
  ),
];

class MediaCard extends StatelessWidget {
  const MediaCard({super.key, required this.item, required this.onTap});

  final MediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(
        child: Icon(
          item.type == MediaType.audio
              ? Icons.music_note
              : Icons.movie_outlined,
        ),
      ),
      title: Text(item.title),
      subtitle: Text(
        '${item.creator} · ${item.type.name} · ${item.sourceType.name}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
