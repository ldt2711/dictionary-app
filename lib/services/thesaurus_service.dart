class ThesaurusModel {
  final String word;
  final List<String> synonyms;
  final String source;

  ThesaurusModel({required this.word, required this.synonyms, required this.source});

  factory ThesaurusModel.fromJson(Map<String, dynamic> json) {
    return ThesaurusModel(
      word: json['word'] ?? '',
      // Backend trả về key "thesauruses"
      synonyms: List<String>.from(json['thesauruses'] ?? []),
      source: json['source'] ?? '',
    );
  }
}