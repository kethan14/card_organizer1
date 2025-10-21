// lib/ui/folders_screen.dart
import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import 'cards_screen.dart';
import 'widgets/folder_tile.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final repo = Repo();
  List<Folder> folders = [];
  Map<int, int> counts = {};
  Map<int, String?> previews = {};

  Future<void> _load() async {
    final fs = await repo.getFolders();
    final newCounts = <int, int>{};
    final newPreviews = <int, String?>{};
    for (final f in fs) {
      final c = await repo.countInFolder(f.id!);
      newCounts[f.id!] = c;
      final first = await repo.firstCardInFolder(f);
      newPreviews[f.id!] = first?.imageUrl;
    }
    setState(() {
      folders = fs;
      counts = newCounts;
      previews = newPreviews;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    const minPerFolder = Repo.minPerFolder;
    const maxPerFolder = Repo.maxPerFolder;

    return Scaffold(
      appBar: AppBar(title: const Text('Card Organizer')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          itemCount: folders.length,
          itemBuilder: (_, i) {
            final f = folders[i];
            return FolderTile(
              folder: f,
              count: counts[f.id] ?? 0,
              previewImageUrl: previews[f.id],
              minPerFolder: minPerFolder,
              maxPerFolder: maxPerFolder,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CardsScreen(folder: f)),
                );
                _load();
              },
            );
          },
        ),
      ),
    );
  }
}
