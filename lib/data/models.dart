// lib/data/models.dart
class Folder {
  final int? id;
  final String name; // Hearts, Spades, Diamonds, Clubs
  final DateTime createdAt;

  Folder({this.id, required this.name, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  Folder copyWith({int? id, String? name, DateTime? createdAt}) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };

  static Folder fromMap(Map<String, dynamic> m) => Folder(
    id: m['id'] as int?,
    name: m['name'] as String,
    createdAt: DateTime.parse(m['createdAt'] as String),
  );
}

class CardItem {
  final int? id;
  final String rank; // "1".."13"
  final String suit; // "Hearts" | "Spades" | "Diamonds" | "Clubs"
  final String imageUrl; // network URL
  final int? folderId; // FK -> folders.id (null means "not placed")

  CardItem({
    this.id,
    required this.rank,
    required this.suit,
    required this.imageUrl,
    this.folderId,
  });

  CardItem copyWith({
    int? id,
    String? rank,
    String? suit,
    String? imageUrl,
    int? folderId,
  }) {
    return CardItem(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      suit: suit ?? this.suit,
      imageUrl: imageUrl ?? this.imageUrl,
      folderId: folderId,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'rank': rank,
    'suit': suit,
    'imageUrl': imageUrl,
    'folderId': folderId,
  };

  static CardItem fromMap(Map<String, dynamic> m) => CardItem(
    id: m['id'] as int?,
    rank: m['rank'] as String,
    suit: m['suit'] as String,
    imageUrl: m['imageUrl'] as String,
    folderId: m['folderId'] as int?,
  );
}
