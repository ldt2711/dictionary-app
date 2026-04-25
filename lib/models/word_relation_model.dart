class WordRelationResult {
  final String word;
  final List<String> synonyms;
  final List<String> antonyms;
  final String source;

  WordRelationResult({
    required this.word,
    required this.synonyms,
    required this.antonyms,
    this.source = '',
  });

  factory WordRelationResult.fromJson(Map<String, dynamic> json) {
    return WordRelationResult(
      word: json['word'] ?? '',
      synonyms: List<String>.from(json['synonyms'] ?? []),
      antonyms: List<String>.from(json['antonyms'] ?? []),
      source: json['source'] ?? '',
    );
  }
}