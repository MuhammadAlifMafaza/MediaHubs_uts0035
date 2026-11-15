import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'device_media_repository.dart';
import 'media_item.dart';
import 'media_navigation.dart';

class DeviceMediaSection extends StatefulWidget {
  const DeviceMediaSection({
    super.key,
    required this.type,
    required this.repository,
  });

  final MediaType type;
  final DeviceMediaRepository repository;

  @override
  State<DeviceMediaSection> createState() => _DeviceMediaSectionState();
}

class _DeviceMediaSectionState extends State<DeviceMediaSection> {
  late Future<DeviceMediaResult> _result;

  @override
  void initState() {
    super.initState();
    _result = widget.repository.load(widget.type);
  }

  @override
  void didUpdateWidget(covariant DeviceMediaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.type != widget.type) {
      _refresh();
    }
  }

  void _refresh() {
    setState(() => _result = widget.repository.load(widget.type));
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'On this device',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            tooltip: 'Scan device media again',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      FutureBuilder<DeviceMediaResult>(
        future: _result,
        builder: (context, snapshot) {
          if (!snapshot.hasData && !snapshot.hasError) {
            return const ListTile(
              title: Text('Scanning device media…'),
              trailing: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return ListTile(
              title: const Text('Unable to scan device media'),
              subtitle: Text('${snapshot.error}'),
              trailing: TextButton(
                onPressed: _refresh,
                child: const Text('Retry'),
              ),
            );
          }
          final result = snapshot.data!;
          if (result.permissionDenied) {
            return ListTile(
              title: const Text('Media access not granted'),
              subtitle: const Text(
                'Allow media access to find files on this device.',
              ),
              trailing: TextButton(
                onPressed: () async {
                  await PhotoManager.openSetting();
                  if (context.mounted) _refresh();
                },
                child: const Text('Settings'),
              ),
            );
          }
          if (result.items.isEmpty) {
            return const ListTile(title: Text('No device media found'));
          }
          return Column(
            children: [
              for (final item in result.items) PlayableMediaCard(item: item),
            ],
          );
        },
      ),
    ],
  );
}
