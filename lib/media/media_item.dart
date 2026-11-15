import 'package:cloud_firestore/cloud_firestore.dart';

enum MediaType { audio, video }

enum MediaSourceType { network, asset, device }

class MediaItem {
  const MediaItem({
    required this.id,
    required this.title,
    required this.creator,
    required this.type,
    required this.sourceType,
    required this.mediaUrl,
    this.description = '',
    this.category = '',
    this.thumbnailUrl = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String creator;
  final MediaType type;
  final String description;
  final String category;
  final MediaSourceType sourceType;
  final String mediaUrl;
  final String thumbnailUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory MediaItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw const FormatException('Media document has no data.');
    }
    return MediaItem.fromMap(snapshot.id, data);
  }

  factory MediaItem.fromMap(String id, Map<String, dynamic> data) {
    final type = MediaType.values.firstWhere(
      (value) => value.name == data['type'],
      orElse: () => throw FormatException('Invalid media type for "$id".'),
    );
    final sourceType = MediaSourceType.values.firstWhere(
      (value) => value.name == data['sourceType'],
      orElse: () =>
          throw FormatException('Invalid media source type for "$id".'),
    );

    return MediaItem(
      id: id,
      title: _requiredString(data, 'title', id),
      creator: _requiredString(data, 'creator', id),
      type: type,
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      sourceType: sourceType,
      mediaUrl: _requiredString(data, 'mediaUrl', id),
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      createdAt: _dateTime(data['createdAt']),
      updatedAt: _dateTime(data['updatedAt']),
    );
  }

  Map<String, Object?> toMap() => {
    'title': title.trim(),
    'creator': creator.trim(),
    'type': type.name,
    'description': description.trim(),
    'category': category.trim(),
    'sourceType': sourceType.name,
    'mediaUrl': mediaUrl.trim(),
    'thumbnailUrl': thumbnailUrl.trim(),
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
  };

  static String _requiredString(
    Map<String, dynamic> data,
    String field,
    String id,
  ) {
    final value = data[field];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Missing or invalid "$field" in media "$id".');
    }
    return value.trim();
  }

  static DateTime? _dateTime(Object? value) => switch (value) {
    Timestamp timestamp => timestamp.toDate(),
    DateTime dateTime => dateTime,
    _ => null,
  };
}
