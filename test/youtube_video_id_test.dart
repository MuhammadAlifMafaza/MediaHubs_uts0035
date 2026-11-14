import 'package:flutter_test/flutter_test.dart';
import 'package:mediahub/player/youtube_video_id.dart';

void main() {
  test('extracts IDs from supported HTTPS YouTube URLs', () {
    expect(
      youtubeVideoId('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
      'dQw4w9WgXcQ',
    );
    expect(youtubeVideoId('https://youtu.be/dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
  });

  test('rejects unrelated, unsafe and incomplete URLs', () {
    expect(
      youtubeVideoId('https://youtube.com.evil.test/watch?v=dQw4w9WgXcQ'),
      isNull,
    );
    expect(youtubeVideoId('http://youtu.be/dQw4w9WgXcQ'), isNull);
    expect(youtubeVideoId('https://www.youtube.com/watch?v=bad'), isNull);
    expect(youtubeVideoId('https://example.com/video.mp4'), isNull);
  });
}
