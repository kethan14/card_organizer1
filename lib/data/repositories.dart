// lib/data/repositories.dart
import 'app_db.dart';
import 'models.dart';

class FolderLimitException implements Exception {
  final String message;
  FolderLimitException(this.message);
  @override
  String toString() => message;
}

class Repo {
  final _db = AppDb();

  // Folder ops
  Future<List<Folder>> getFolders() => _db.getFolders();
  Future<int> renameFolder(Folder f, String newName) =>
      _db.updateFolder(f.copyWith(name: newName));
  Future<int> deleteFolder(Folder f) => _db.deleteFolder(f.id!);

  Future<int> countInFolder(int folderId) => _db.countCardsInFolder(folderId);

  // Card ops with limits
  static const minPerFolder = 3;
  static const maxPerFolder = 6;

  Future<void> addCardToFolder(CardItem card, Folder folder) async {
    final count = await _db.countCardsInFolder(folder.id!);
    if (count >= maxPerFolder) {
      throw FolderLimitException(
        'This folder can only hold $maxPerFolder cards.',
      );
    }
    await _db.updateCard(card.copyWith(folderId: folder.id));
  }

  Future<void> moveCard(CardItem card, Folder toFolder) async {
    final count = await _db.countCardsInFolder(toFolder.id!);
    if (count >= maxPerFolder) {
      throw FolderLimitException(
        'This folder can only hold $maxPerFolder cards.',
      );
    }
    await _db.updateCard(card.copyWith(folderId: toFolder.id));
  }

  Future<void> removeCard(CardItem card) async {
    // Removing from folder (set folderId to null)
    await _db.updateCard(card.copyWith(folderId: null));
  }

  Future<List<CardItem>> cardsInFolder(Folder folder) =>
      _db.getCards(folderId: folder.id);

  Future<CardItem?> firstCardInFolder(Folder folder) =>
      _db.getFirstCardInFolder(folder.id!);

  Future<List<CardItem>> unassignedBySuit(String suit) =>
      _db.getCards(suit: suit, onlyUnassigned: true);

  Future<List<CardItem>> fullDeckUnassigned() =>
      _db.getCards(onlyUnassigned: true);
}
