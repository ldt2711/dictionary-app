import 'package:flutter/material.dart';
import '../services/translation_service.dart';

// Model đơn giản để lưu lịch sử dịch
class TranslationHistory {
  final String origin;
  final String translated;
  final String fromLang;
  final String toLang;

  TranslationHistory({
    required this.origin,
    required this.translated,
    required this.fromLang,
    required this.toLang,
  });
}

class TranslationProvider with ChangeNotifier {
  final TranslationService _service = TranslationService();

  String _resultText = "";
  bool _isLoading = false;
  String _sourceLanguage = "Tiếng Việt";
  String _targetLanguage = "English";

  final List<TranslationHistory> _history = [];

  String get resultText => _resultText;
  bool get isLoading => _isLoading;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  List<TranslationHistory> get history => _history;

  // ===========================================================
  // 1. PHẦN CẦN THÊM: Hàm để load dữ liệu từ lịch sử ngược lại UI
  // ===========================================================
  void loadHistoryItem(TranslationHistory item, TextEditingController controller) {
    _sourceLanguage = item.fromLang;
    _targetLanguage = item.toLang;
    _resultText = item.translated;
    
    // Cập nhật text hiển thị trên khung nhập liệu (Textfield)
    controller.text = item.origin;
    
    // Thông báo cho các widget (Card, Header...) cập nhật lại giao diện
    notifyListeners();
  }

  void swapLanguages(TextEditingController controller) {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;

    if (_resultText.isNotEmpty && !_resultText.startsWith("Error:")) {
      String cleanText = _resultText.replaceAll("Translated: ", "");
      controller.text = cleanText;
      _resultText = ""; 
    }
    notifyListeners();
  }

  Future<void> handleTranslation(String input) async {
    if (input.trim().isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final langCode = _targetLanguage == "English" ? "en" : "vi";
      final result = await _service.translate(input, langCode);
      
      if (result != null) {
        _resultText = result.translatedText;
        
        _history.insert(0, TranslationHistory(
          origin: input,
          translated: _resultText,
          fromLang: _sourceLanguage,
          toLang: _targetLanguage,
        ));
      } else {
        _resultText = "Error: Could not get translation from server.";
      }
    } catch (e) {
      _resultText = "Error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}