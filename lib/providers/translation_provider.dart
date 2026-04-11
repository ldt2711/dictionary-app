import 'package:flutter/material.dart';
import '../models/translation_history.dart'; 
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

  // --- MỚI THÊM: Danh sách các ngôn ngữ hỗ trợ ---
  static const Map<String, String> supportedLanguages = {
    'Tiếng Việt': 'vi',
    'English': 'en',
    'Français (Pháp)': 'fr',
    '日本語 (Nhật)': 'ja',
    '한국어 (Hàn)': 'ko',
    '中文 (Trung)': 'zh-CN',
    'Español (Tây Ban Nha)': 'es',
    'Deutsch (Đức)': 'de',
    'Русский (Nga)': 'ru',
    'ภาษาไทย (Thái)': 'th',
  };

  // Getters
  String get resultText => _resultText;
  bool get isLoading => _isLoading;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String get currentSourceAudio => _currentSourceAudio;
  String get currentTargetAudio => _currentTargetAudio;
  List<TranslationHistory> get history => _history;

  // --- MỚI THÊM: Các hàm để UI cập nhật ngôn ngữ ---
  void setSourceLanguage(String lang) {
    _sourceLanguage = lang;
    notifyListeners();
  }

  void setTargetLanguage(String lang) {
    _targetLanguage = lang;
    notifyListeners();
  }

  // --- CẬP NHẬT LẠI: Lấy mã ngôn ngữ từ Map ---
  String _getLangCode(String name) {
    return supportedLanguages[name] ?? 'en'; // Mặc định là 'en' nếu không tìm thấy
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

  void clearHistory() {
    _history.clear();
    _resultText = "";
    _currentSourceAudio = "";
    _currentTargetAudio = "";
    notifyListeners();
  }

  Future<void> fetchUserHistory(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedHistory = await _service.getUserHistory(userId);
      
      if (fetchedHistory != null) {
        _history.clear(); 
        _history.addAll(fetchedHistory); 
      }
    } catch (e) {
      debugPrint("Lỗi tải lịch sử: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleTranslation(String input, {int? userId}) async {
    if (input.trim().isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final sCode = _getLangCode(_sourceLanguage);
      final tCode = _getLangCode(_targetLanguage);

      final result = await _service.translate(
        input, 
        sCode, 
        tCode, 
        userId: userId, 
      );
      
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