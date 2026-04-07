class DictionaryResult {
  final String word;
  final String pronunciation;
  final List<Definition> definitions;
  final List<String> grammarTips;

  DictionaryResult({
    required this.word,
    required this.pronunciation,
    required this.definitions,
    required this.grammarTips,
  });

  // ADD THIS: The logic to convert JSON into this class
  factory DictionaryResult.fromJson(Map<String, dynamic> json) {
    return DictionaryResult(
      word: json['word'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      // This part handles the list of definitions
      definitions: (json['definitions'] as List)
          .map((d) => Definition.fromJson(d))
          .toList(),
      // This handles the list of strings
      grammarTips: List<String>.from(json['grammarTips'] ?? []),
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

  // ADD THIS: Logic for the nested definition objects
  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      partOfSpeech: json['partOfSpeech'] ?? '',
      meaning: json['meaning'] ?? '',
      example: json['example'] ?? '',
    );
  }
}