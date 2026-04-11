import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // 1. Add this import
import '../models/word_model.dart';

class DictionaryDisplayWidget extends StatefulWidget {
  final DictionaryResult? data;

  const DictionaryDisplayWidget({super.key, this.data});

  @override
  State<DictionaryDisplayWidget> createState() => _DictionaryDisplayWidgetState();
}

class _DictionaryDisplayWidgetState extends State<DictionaryDisplayWidget> {
  // 2. Initialize the AudioPlayer
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    // 3. Always dispose the player to prevent memory leaks
    _audioPlayer.dispose();
    super.dispose();
  }

  // 4. Function to trigger the audio
  Future<void> _playAudio(String url) async {
    if (url.isNotEmpty) {
      try {
        await _audioPlayer.play(UrlSource(url));
      } catch (e) {
        debugPrint("Audio error: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No audio available for this word")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Data mapping
    final String word = widget.data?.word ?? "Lucullan";
    final String pronunciation = widget.data?.pronunciation ?? "[loo-kuhl-uhn]";
    final String audioUrl = widget.data?.audio ?? ""; // From your updated model
    
    final List<String> definitions = widget.data != null 
        ? widget.data!.definitions.map((d) => d.meaning).toList()
        : [
            "(especially of banquets, parties, etc.) marked by lavishness and richness;",
            "of or relating to Lucullus or his lifestyle."
          ];

    return Container(
      width: 800,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
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
                        color: Color(0xFF2962FF),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        // --- 5. Updated Volume Icon to be a Button ---
                        IconButton(
                          icon: const Icon(Icons.volume_up_outlined, color: Color(0xFF6B52FF), size: 22),
                          onPressed: () => _playAudio(audioUrl),
                          tooltip: "Listen",
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
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
              
              // Right Column
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Definition",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
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