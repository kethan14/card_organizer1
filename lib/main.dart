// lib/main.dart
import 'package:flutter/material.dart';
import 'data/app_db.dart';
import 'data/seed.dart';
import 'ui/folders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // init DB & seed
  await AppDb().database;
  await Seeder.ensureSeeded();
  runApp(const CardOrganizerApp());
}

class CardOrganizerApp extends StatelessWidget {
  const CardOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5),
      ),
      home: const FoldersScreen(),
    );
  }
}
