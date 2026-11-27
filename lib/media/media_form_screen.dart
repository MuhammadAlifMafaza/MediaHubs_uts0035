import 'package:flutter/material.dart';

import 'media_item.dart';
import 'media_catalog.dart';

class MediaFormScreen extends StatefulWidget {
  const MediaFormScreen({super.key, this.initialItem, this.onSave});

  final MediaItem? initialItem;
  final Future<void> Function(MediaItem item)? onSave;

  @override
  State<MediaFormScreen> createState() => _MediaFormScreenState();
}

class _MediaFormScreenState extends State<MediaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _creatorController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _locatorController;
  late MediaType _type;
  late MediaSourceType _sourceType;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _creatorController = TextEditingController(text: item?.creator ?? '');
    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    _categoryController = TextEditingController(text: item?.category ?? '');
    _locatorController = TextEditingController(text: item?.mediaUrl ?? '');
    _type = item?.type ?? MediaType.audio;
    _sourceType = item?.sourceType ?? MediaSourceType.network;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _creatorController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _locatorController.dispose();
    super.dispose();
  }

  String? _validateLocator(String? value) {
    final locator = value?.trim() ?? '';
    if (locator.isEmpty) return 'Media URL/path is required.';
    if (_sourceType == MediaSourceType.network) {
      final uri = Uri.tryParse(locator);
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty) {
        return 'Enter a valid HTTPS media URL.';
      }
    } else if (!demoMediaItems.any(
      (item) => item.mediaUrl == locator && item.type == _type,
    )) {
      return 'Select a bundled asset path matching the media type.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || widget.onSave == null) return;
    setState(() => _saving = true);
    final item = MediaItem(
      id: widget.initialItem?.id ?? '',
      title: _titleController.text.trim(),
      creator: _creatorController.text.trim(),
      type: _type,
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      sourceType: _sourceType,
      mediaUrl: _locatorController.text.trim(),
      thumbnailUrl: widget.initialItem?.thumbnailUrl ?? '',
      createdAt: widget.initialItem?.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      await widget.onSave!(item);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save media: $error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initialItem != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit media' : 'Add media')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (widget.onSave == null)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Cloud saving is not enabled yet'),
                  subtitle: Text(
                    'Create the Firestore database and publish the reviewed public Rules before enabling writes.',
                  ),
                ),
              ),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Title *'),
              validator: (value) =>
                  (value?.trim().isEmpty ?? true) ? 'Title is required.' : null,
            ),
            TextFormField(
              controller: _creatorController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Creator *'),
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'Creator is required.'
                  : null,
            ),
            DropdownButtonFormField<MediaType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Media type *'),
              items: MediaType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value != null) setState(() => _type = value);
                    },
            ),
            DropdownButtonFormField<MediaSourceType>(
              initialValue: _sourceType,
              decoration: const InputDecoration(labelText: 'Source *'),
              items: MediaSourceType.values
                  .where((source) => source != MediaSourceType.device)
                  .map(
                    (source) => DropdownMenuItem(
                      value: source,
                      child: Text(source.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value != null) setState(() => _sourceType = value);
                    },
            ),
            if (_sourceType == MediaSourceType.asset)
              DropdownButtonFormField<String>(
                initialValue:
                    demoMediaItems.any(
                      (item) =>
                          item.mediaUrl == _locatorController.text &&
                          item.type == _type,
                    )
                    ? _locatorController.text
                    : null,
                decoration: const InputDecoration(labelText: 'Bundled asset'),
                items: demoMediaItems
                    .where((item) => item.type == _type)
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.mediaUrl,
                        child: Text(item.title),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _locatorController.text = value);
                  }
                },
              ),
            TextFormField(
              controller: _locatorController,
              keyboardType: _sourceType == MediaSourceType.network
                  ? TextInputType.url
                  : TextInputType.text,
              decoration: InputDecoration(
                labelText: _sourceType == MediaSourceType.network
                    ? 'HTTPS media URL *'
                    : 'Registered asset path *',
              ),
              validator: _validateLocator,
            ),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextFormField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: widget.onSave == null || _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(editing ? 'Save changes' : 'Save media'),
            ),
          ],
        ),
      ),
    );
  }
}
