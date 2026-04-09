class TranslationResult {
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final String sourceAudio; // URL link to the source TTS
  final String targetAudio; // URL link to the translated TTS
  final String source;      // To know if it came from "database" or "api"

  TranslationResult({
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.sourceAudio,
    required this.targetAudio,
    required this.source,
  });

  factory TranslationResult.fromJson(Map<String, dynamic> json) {
    return TranslationResult(
      // Match the keys exactly as they appear in your main.py jsonify()
      translatedText: json['translatedText'] ?? '',
      sourceLang: json['source_lang'] ?? 'en',
      targetLang: json['target_lang'] ?? 'vi',
      sourceAudio: json['source_audio'] ?? '',
      targetAudio: json['target_audio'] ?? '',
      source: json['source'] ?? 'api',
    );
  }
}