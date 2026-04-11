class DictionaryResult {
  final String word;
  final String pronunciation;
  final List<Definition> definitions;
  final List<String> grammarTips;
  final String audio; // 1. Add this field

  DictionaryResult({
    required this.word,
    required this.pronunciation,
    required this.definitions,
    required this.grammarTips,
    required this.audio, // 2. Add to constructor
  });

  factory DictionaryResult.fromJson(Map<String, dynamic> json) {
    return DictionaryResult(
      word: json['word'] ?? '',
      pronunciation: json['phonetic'] ?? '', 
      definitions: (json['meanings'] as List?)
              ?.map((d) => Definition.fromJson(d))
              .toList() ?? [],
      grammarTips: [],
      audio: json['audio'] ?? '', // 3. Map 'audio' from Flask
    );
  }
}

class Definition {
  final String partOfSpeech;
  final String meaning;
  final String example;

  Definition({
    required this.partOfSpeech,
    required this.meaning,
    required this.example,
  });

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      // Map 'pos' from Flask to 'partOfSpeech'
      partOfSpeech: json['pos'] ?? '', 
      meaning: json['meaning'] ?? '',
      example: json['example'] ?? '',
    );
  }
}