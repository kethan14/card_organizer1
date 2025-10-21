// lib/ui/cards_screen.dart
import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../data/app_db.dart'; // ✅ added import to access AppDb()
import 'widgets/card_tile.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;
  const CardsScreen({super.key, required this.folder});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final repo = Repo();
  List<CardItem> cards = [];

  // Load all cards currently in this folder
  Future<void> _load() async {
    final c = await repo.cardsInFolder(widget.folder);
    setState(() => cards = c);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Show error message dialog
  Future<void> _showError(String msg) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notice'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Add a card to this folder (only if under max limit)
  Future<void> _addCard() async {
    final unassigned = await repo.unassignedBySuit(widget.folder.name);
    if (unassigned.isEmpty) {
      await _showError('No more unassigned ${widget.folder.name} cards left.');
      return;
    }
    if (cards.length >= Repo.maxPerFolder) {
      await _showError('This folder can only hold ${Repo.maxPerFolder} cards.');
      return;
    }

    if (!mounted) return;
    final selected = await showModalBottomSheet<CardItem>(
      context: context,
      builder: (_) => _CardPicker(items: unassigned),
    );

    if (selected != null) {
      try {
        await repo.addCardToFolder(selected, widget.folder);
        await _load();
      } on FolderLimitException catch (e) {
        await _showError(e.message);
      }
    }
  }

  // Move a card to another folder
  Future<void> _moveCard(CardItem c) async {
    if (!mounted) return;
    final folders = await repo.getFolders();
    final choices = folders.where((f) => f.id != c.folderId).toList();

    final to = await showModalBottomSheet<Folder>(
      context: context,
      builder: (_) => _FolderPicker(items: choices),
    );

    if (to != null) {
      try {
        await repo.moveCard(c, to);
        await _load();
      } on FolderLimitException catch (e) {
        await _showError(e.message);
      }
    }
  }

  // Remove card from folder (unassign)
  Future<void> _removeCard(CardItem c) async {
    await repo.removeCard(c);
    await _load();
  }

  // Delete card record completely
  Future<void> _deleteCard(CardItem c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete card record?'),
        content: const Text(
          'This removes the card from the database. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await repo.removeCard(c); // ensure unlink first
      await AppDb().deleteCard(c.id!); // ✅ fixed (replaced repo._db)
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final warnLow = cards.length < Repo.minPerFolder;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.folder.name} (${cards.length})'),
        actions: [
          if (warnLow)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Need at least ${Repo.minPerFolder}',
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCard,
        label: const Text('Add Card'),
        icon: const Icon(Icons.add),
      ),
      body: cards.isEmpty
          ? const Center(child: Text('No cards here yet. Tap "Add Card".'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemCount: cards.length,
              itemBuilder: (_, i) {
                final c = cards[i];
                return CardTile(
                  card: c,
                  onRemove: () => _removeCard(c),
                  onMove: () => _moveCard(c),
                  onDelete: () => _deleteCard(c),
                );
              },
            ),
    );
  }
}

//
// -------------------------
//   Card Picker Sheet
// -------------------------
class _CardPicker extends StatelessWidget {
  final List<CardItem> items;
  const _CardPicker({required this.items});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final c = items[i];
          return ListTile(
            title: Text('${c.rank} of ${c.suit}'),
            subtitle: Text(
              c.imageUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => Navigator.pop(context, c),
          );
        },
      ),
    );
  }
}

//
// -------------------------
//   Folder Picker Sheet
// -------------------------
class _FolderPicker extends StatelessWidget {
  final List<Folder> items;
  const _FolderPicker({required this.items});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final f = items[i];
          return ListTile(
            title: Text(f.name),
            onTap: () => Navigator.pop(context, f),
          );
        },
      ),
    );
  }
}
