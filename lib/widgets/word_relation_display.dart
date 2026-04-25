import 'package:flutter/material.dart';
import '../models/word_relation_model.dart';

class WordRelationDisplay extends StatelessWidget {
  final WordRelationResult data;
  const WordRelationDisplay({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.compare_arrows, color: Colors.blue),
              SizedBox(width: 10),
              Text("Thesaurus", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _buildRow("Synonyms", data.synonyms, Colors.green),
          if (data.antonyms.isNotEmpty) ...[
            const Divider(height: 30),
            _buildRow("Antonyms", data.antonyms, Colors.red),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String title, List<String> words, MaterialColor color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: color[700], fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: words.take(5).map((w) => Container( 
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Text(w, style: TextStyle(color: color[700], fontSize: 13)),
          )).toList(),
        ),
      ],
    );
  }
}