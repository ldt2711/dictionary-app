import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/dictionary_service.dart';

class DictionaryProvider with ChangeNotifier {
  final DictionaryService _service = DictionaryService();
  
  DictionaryResult? _result;
  bool _isLoading = false;
  
  // Thêm danh sách lưu lịch sử tìm kiếm (có thể để sẵn vài từ test)
  final List<String> _searchHistory = [];

  DictionaryResult? get result => _result;
  bool get isLoading => _isLoading;
  List<String> get searchHistory => _searchHistory;

  Future<void> searchWord(String word) async {
    _isLoading = true;
    notifyListeners();

    // Thêm từ vào lịch sử khi bắt đầu tìm kiếm
    addToHistory(word);

    _result = await _service.getWordData(word);

    _isLoading = false;
    notifyListeners();
  }

  // Hàm thêm vào lịch sử
  void addToHistory(String word) {
    if (word.trim().isEmpty) return;
    // Xóa nếu từ đã tồn tại để đẩy nó lên đầu danh sách
    _searchHistory.remove(word);
    _searchHistory.insert(0, word);
    // Giới hạn lưu tối đa 10 từ gần nhất
    if (_searchHistory.length > 10) {
      _searchHistory.removeLast();
    }
    notifyListeners();
  }

  // Hàm xóa một từ khỏi lịch sử
  void removeFromHistory(String word) {
    _searchHistory.remove(word);
    notifyListeners();
  }
}