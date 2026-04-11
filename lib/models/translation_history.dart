class TranslationHistory {
  final String origin;
  final String translated;
  final String fromLang;
  final String toLang;
  final String sourceAudio;
  final String targetAudio;

  TranslationHistory({
    required this.origin,
    required this.translated,
    required this.fromLang,
    required this.toLang,
    required this.sourceAudio,
    required this.targetAudio,
  });
}