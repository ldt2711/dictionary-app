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

  factory ThesaurusResult.fromJson(Map<String, dynamic> json) {
    return ThesaurusResult(
      word: json['word'] ?? '',
      // SỬA CHỖ NÀY: Backend Flask trả về mảng đồng nghĩa dưới tên key là "thesauruses"
      synonyms: List<String>.from(json['thesauruses'] ?? []), 
      
      // Mấy cái này API chưa trả về, cứ để [] cho an toàn
      antonyms: List<String>.from(json['antonyms'] ?? []),
      relatedPhrases: List<String>.from(json['relatedPhrases'] ?? []),
    );
  }

  factory ThesaurusResult.mock(String word) {
    return ThesaurusResult(
      word: word,
      synonyms: ["reliable", "steadfast", "devoted", "constant"],
      antonyms: ["unfaithful", "disloyal", "fickle"],
      relatedPhrases: ["true to one's word", "keep the faith"],
    );
  }
}