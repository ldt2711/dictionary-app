import 'package:flutter/material.dart';
import '../models/word_model.dart'; // Make sure your path is correct

class DictionaryDisplayWidget extends StatelessWidget {
  final DictionaryResult? data; // Made nullable for the default state

  const DictionaryDisplayWidget({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    // Use real data if available, otherwise default to Figma mockup text
    final String word = data?.word ?? "Lucullan";
    final String pronunciation = data?.pronunciation ?? "[loo-kuhl-uhn]";
    
    // Default definitions if data is null
    final List<String> definitions = data != null 
        ? data!.definitions.map((d) => d.meaning).toList()
        : [
            "(especially of banquets, parties, etc.) marked by lavishness and richness;",
            "of or relating to Lucullus or his lifestyle."
          ];

    return Container(
      width: 800, // Match the wide card look
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Word of the day",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Word and Pronunciation
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2962FF), // Blue text
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(Icons.volume_up_outlined, color: Color(0xFF6B52FF), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          pronunciation,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              
              // Right Column: Adjective and Definitions
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Adjective",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Map through definitions and number them
                    ...List.generate(definitions.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${index + 1}. ", style: const TextStyle(fontSize: 15, height: 1.5)),
                            Expanded(
                              child: Text(
                                definitions[index],
                                style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}