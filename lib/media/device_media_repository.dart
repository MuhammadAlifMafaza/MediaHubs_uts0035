import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

import 'media_item.dart';

class DeviceMediaResult {
  const DeviceMediaResult({required this.items, this.permissionDenied = false});

  final List<MediaItem> items;
  final bool permissionDenied;
}

abstract interface class DeviceMediaRepository {
  Future<DeviceMediaResult> load(MediaType type);
}

class PhotoManagerDeviceMediaRepository implements DeviceMediaRepository {
  const PhotoManagerDeviceMediaRepository();

  @override
  Future<DeviceMediaResult> load(MediaType type) async {
    if (!Platform.isAndroid) return const DeviceMediaResult(items: []);
    final requestType = type == MediaType.audio
        ? RequestType.audio
        : RequestType.video;
    final permission = await PhotoManager.requestPermissionExtend(
      requestOption: PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: requestType,
          mediaLocation: false,
        ),
      ),
    );
    if (permission != PermissionState.authorized &&
        permission != PermissionState.limited) {
      return const DeviceMediaResult(items: [], permissionDenied: true);
    }

    final paths = await PhotoManager.getAssetPathList(
      type: requestType,
      onlyAll: true,
    );
    if (paths.isEmpty) return const DeviceMediaResult(items: []);
    final items = <MediaItem>[];
    const pageSize = 100;
    for (var page = 0; ; page++) {
      final assets = await paths.first.getAssetListPaged(
        page: page,
        size: pageSize,
      );
      for (final asset in assets) {
        final title = asset.title?.trim();
        items.add(
          MediaItem(
            id: 'device-${type.name}-${asset.id}',
            title: title == null || title.isEmpty ? 'Untitled media' : title,
            creator: 'On this device',
            type: type,
            sourceType: MediaSourceType.device,
            // Resolved to a content URI when the user selects the item.
            mediaUrl: asset.id,
          ),
        );
      }
      if (assets.length < pageSize) break;
    }
    return DeviceMediaResult(items: items);
  }
}
