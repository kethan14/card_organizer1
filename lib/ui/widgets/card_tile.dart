// lib/ui/widgets/card_tile.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/models.dart';

class CardTile extends StatelessWidget {
  final CardItem card;
  final VoidCallback onRemove;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  const CardTile({
    super.key,
    required this.card,
    required this.onRemove,
    required this.onMove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = '${card.rank} of ${card.suit}';
    return Card(
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: card.imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.broken_image_outlined, size: 40),
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: 'Remove from folder',
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: onRemove,
              ),
              IconButton(
                tooltip: 'Move to another folder',
                icon: const Icon(Icons.drive_file_move_outline),
                onPressed: onMove,
              ),
              IconButton(
                tooltip: 'Delete card record',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
