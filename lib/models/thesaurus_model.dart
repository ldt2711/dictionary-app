class ThesaurusResult {
  final String word;
  final List<String> synonyms;
  final List<String> antonyms;
  final List<String> relatedPhrases;

  ThesaurusResult({
    required this.word,
    required this.synonyms,
    required this.antonyms,
    required this.relatedPhrases,
  });

  // --- THE FIX: Add this logic to handle the JSON file ---
  factory ThesaurusResult.fromJson(Map<String, dynamic> json) {
    return ThesaurusResult(
      word: json['word'] ?? '',
      // List<String>.from ensures the dynamic JSON list becomes a clean String list
      synonyms: List<String>.from(json['synonyms'] ?? []),
      antonyms: List<String>.from(json['antonyms'] ?? []),
      relatedPhrases: List<String>.from(json['relatedPhrases'] ?? []),
    );
  }

  // Keeping your mock here is fine for testing!
  factory ThesaurusResult.mock(String word) {
    return ThesaurusResult(
      word: word,
      synonyms: ["reliable", "steadfast", "devoted", "constant"],
      antonyms: ["unfaithful", "disloyal", "fickle"],
      relatedPhrases: ["true to one's word", "keep the faith"],
    );
  }
}