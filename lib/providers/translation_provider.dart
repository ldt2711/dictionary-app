import 'package:flutter/material.dart';
import '../models/translation_history.dart'; // <--- Now this works!
import '../services/translation_service.dart';

class TranslationProvider with ChangeNotifier {
  final TranslationService _service = TranslationService();

  String _resultText = "";
  bool _isLoading = false;
  String _sourceLanguage = "Tiếng Việt";
  String _targetLanguage = "English";
  
  String _currentSourceAudio = "";
  String _currentTargetAudio = "";

  final List<TranslationHistory> _history = [];

  // Getters
  String get resultText => _resultText;
  bool get isLoading => _isLoading;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String get currentSourceAudio => _currentSourceAudio;
  String get currentTargetAudio => _currentTargetAudio;
  List<TranslationHistory> get history => _history;

  String _getLangCode(String name) {
    return name == "Tiếng Việt" ? "vi" : "en";
  }

  void loadHistoryItem(TranslationHistory item, TextEditingController controller) {
    _sourceLanguage = item.fromLang;
    _targetLanguage = item.toLang;
    _resultText = item.translated;
    _currentSourceAudio = item.sourceAudio;
    _currentTargetAudio = item.targetAudio;
    
    controller.text = item.origin;
    notifyListeners();
  }

  void swapLanguages(TextEditingController controller) {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;

    if (_resultText.isNotEmpty && !_resultText.startsWith("Error:")) {
      controller.text = _resultText;
      _resultText = ""; 
    }
    notifyListeners();
  }

  Future<void> handleTranslation(String input) async {
    if (input.trim().isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final sCode = _getLangCode(_sourceLanguage);
      final tCode = _getLangCode(_targetLanguage);

      // This fix matches your rewritten TranslationService
      final result = await _service.translate(input, sCode, tCode);
      
      if (result != null) {
        _resultText = result.translatedText;
        _currentSourceAudio = result.sourceAudio;
        _currentTargetAudio = result.targetAudio;
        
        _history.insert(0, TranslationHistory(
          origin: input,
          translated: _resultText,
          fromLang: _sourceLanguage,
          toLang: _targetLanguage,
          sourceAudio: result.sourceAudio,
          targetAudio: result.targetAudio,
        ));
      } else {
        _resultText = "Error: Translation failed.";
      }
    } catch (e) {
      _resultText = "Error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}