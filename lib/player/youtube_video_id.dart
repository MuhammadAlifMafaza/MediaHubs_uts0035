import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Only accept HTTPS YouTube links; the iframe package extracts the video ID.
String? youtubeVideoId(String input) {
  final uri = Uri.tryParse(input.trim());
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.userInfo.isNotEmpty ||
      uri.hasPort) {
    return null;
  }
  if (!{
    'youtube.com',
    'www.youtube.com',
    'm.youtube.com',
    'youtu.be',
  }.contains(uri.host.toLowerCase())) {
    return null;
  }
  final id = YoutubePlayerController.convertUrlToId(uri.toString());
  return id != null && RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id) ? id : null;
}
