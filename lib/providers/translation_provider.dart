import 'package:flutter/material.dart';
import '../models/translation_history.dart'; 
import '../services/translation_service.dart';
import '../services/api_service.dart'; // THÊM IMPORT NÀY

class TranslationProvider with ChangeNotifier {
  final TranslationService _service = TranslationService();
  final ApiService _apiService = ApiService(); // Khởi tạo để gọi API

  String _resultText = "";
  bool _isLoading = false;
  
  // Mặc định ban đầu, sau khi load từ API sẽ cập nhật lại
  String _sourceLanguage = "vietnamese"; 
  String _targetLanguage = "english";
  
  String _currentSourceAudio = "";
  String _currentTargetAudio = "";

  final List<TranslationHistory> _history = [];

  // --- THAY ĐỔI QUAN TRỌNG: Danh sách ngôn ngữ động từ API ---
  Map<String, String> _supportedLanguages = {};

  // Getters
  String get resultText => _resultText;
  bool get isLoading => _isLoading;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String get currentSourceAudio => _currentSourceAudio;
  String get currentTargetAudio => _currentTargetAudio;
  List<TranslationHistory> get history => _history;
  Map<String, String> get supportedLanguages => _supportedLanguages;

  // --- HÀM 1: Tải danh sách ngôn ngữ từ Flask ---
  Future<void> loadLanguagesFromServer() async {
    _isLoading = true;
    notifyListeners();
    try {
      final langs = await _apiService.fetchLanguages();
      if (langs.isNotEmpty) {
        _supportedLanguages = langs;
        // Kiểm tra xem có 'vietnamese' và 'english' trong list mới không để set default
        if (!_supportedLanguages.containsKey(_sourceLanguage)) {
          _sourceLanguage = _supportedLanguages.keys.first;
        }
      }
    } catch (e) {
      debugPrint("Lỗi tải ngôn ngữ: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper để lấy mã code (vi, en...)
  String _getLangCode(String name) {
    return _supportedLanguages[name.toLowerCase()] ?? 'en';
  }

  // --- HÀM 2: Cập nhật ngôn ngữ (Dùng cho Dropdown) ---
  void setSourceLanguage(String lang) {
    _sourceLanguage = lang.toLowerCase();
    notifyListeners();
  }

  void setTargetLanguage(String lang) {
    _targetLanguage = lang.toLowerCase();
    notifyListeners();
  }

  // --- HÀM 3: Đổi chỗ 2 ngôn ngữ ---
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

  // --- HÀM 4: Tải lịch sử (History) ---
  Future<void> fetchUserHistory(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Truyền thêm _supportedLanguages để Service biết cách dịch mã code thành tên
      final fetchedHistory = await _service.getUserHistory(userId, _supportedLanguages);
      
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

  // --- HÀM 5: Xử lý dịch thuật chính ---
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
        
        // Thêm vào lịch sử hiển thị ngay lập tức (UI)
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

  void loadHistoryItem(TranslationHistory item, TextEditingController controller) {
    _sourceLanguage = item.fromLang.toLowerCase();
    _targetLanguage = item.toLang.toLowerCase();
    _resultText = item.translated;
    _currentSourceAudio = item.sourceAudio;
    _currentTargetAudio = item.targetAudio;
    
    controller.text = item.origin;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _resultText = "";
    _currentSourceAudio = "";
    _currentTargetAudio = "";
    notifyListeners();
  }

  void resetCurrentTranslation() {
    _resultText = "";
    _currentSourceAudio = "";
    _currentTargetAudio = "";
    notifyListeners();
  }
}