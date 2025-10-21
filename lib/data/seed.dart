// lib/data/seed.dart
import 'app_db.dart';
import 'models.dart';

class Seeder {
  static const suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];

  static Future<void> ensureSeeded() async {
    final db = AppDb();

    // Add the 4 folders if missing
    for (final s in suits) {
      final exists = await db.getFolderByName(s);
      if (exists == null) {
        await db.insertFolder(Folder(name: s));
      }
    }

    // Prepopulate full deck if empty
    final existing = await db.getCards();
    if (existing.isEmpty) {
      for (final suit in suits) {
        for (int r = 1; r <= 13; r++) {
          final rankCode = _rankCode(r); // "A","2"...,"0"(10),"J","Q","K"
          final suitCode = _suitCode(suit); // "H","S","D","C"
          final code = '$rankCode$suitCode';
          final imageUrl = 'https://deckofcardsapi.com/static/img/$code.png';
          await db.insertCard(
            CardItem(
              rank: r.toString(),
              suit: suit,
              imageUrl: imageUrl,
              folderId: null, // not placed yet
            ),
          );
        }
      }
    }
  }

  static String _rankCode(int r) {
    if (r == 1) return 'A';
    if (r >= 2 && r <= 9) return r.toString();
    if (r == 10) return '0';
    if (r == 11) return 'J';
    if (r == 12) return 'Q';
    return 'K';
  }

  static String _suitCode(String suit) {
    switch (suit) {
      case 'Hearts':
        return 'H';
      case 'Spades':
        return 'S';
      case 'Diamonds':
        return 'D';
      case 'Clubs':
        return 'C';
      default:
        return 'S';
    }
  }
}
