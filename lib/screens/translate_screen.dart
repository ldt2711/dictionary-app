import 'package:flutter/material.dart';
import '../widgets/translation_card.dart';

class TranslateScreen extends StatelessWidget {
  const TranslateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We return just the UI for the translate section.
    // The Navbar is handled by the parent screen.
    return Padding(
      // Pushing it down from the navbar to center it nicely
      padding: const EdgeInsets.only(top: 100, bottom: 50, left: 20, right: 20),
      child: Center(
        child: TranslationCard(),
      ),
    );
  }
}