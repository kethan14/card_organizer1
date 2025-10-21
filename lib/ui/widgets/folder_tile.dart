// lib/ui/widgets/folder_tile.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/models.dart';

class FolderTile extends StatelessWidget {
  final Folder folder;
  final int count;
  final String? previewImageUrl;
  final int minPerFolder;
  final int maxPerFolder;
  final VoidCallback onTap;
  const FolderTile({
    super.key,
    required this.folder,
    required this.count,
    required this.previewImageUrl,
    required this.minPerFolder,
    required this.maxPerFolder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final warnLow = count < minPerFolder;
    final warnHigh = count > maxPerFolder;
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade200,
                ),
                child: previewImageUrl == null
                    ? const Icon(Icons.image_not_supported_outlined, size: 36)
                    : CachedNetworkImage(
                        imageUrl: previewImageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.broken_image_outlined),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$count card(s)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (warnLow)
                      Text(
                        'You need at least $minPerFolder cards.',
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    if (warnHigh)
                      Text(
                        'Over max ($maxPerFolder).',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
