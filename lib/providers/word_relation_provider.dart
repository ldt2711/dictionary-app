import 'package:flutter/material.dart';
import '../models/word_relation_model.dart';
import '../services/word_relation_service.dart'; // Import service mới

class WordRelationProvider extends ChangeNotifier {
  // Sử dụng Service thay vì gọi trực tiếp ApiService
  final WordRelationService _service = WordRelationService(); 
  
  WordRelationResult? _result;
  bool _isLoading = false;
  String? _errorMessage;
  final List<String> _searchHistory = [];

  // Getters
  WordRelationResult? get result => _result;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get searchHistory => _searchHistory;

  Future<void> searchWordRelation(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _result = null;
    _errorMessage = null;
    notifyListeners();

    addToHistory(query);

    try {
      // Gọi service để lấy dữ liệu (Giống cách DictionaryProvider làm)
      final data = await _service.getWordRelation(query);

      if (data == null) {
        _errorMessage = "We couldn't find data for '$query'";
      } else {
        _result = data;
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = "Something went wrong. Please check connection.";
      debugPrint("WordRelation Provider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- HISTORY MANAGEMENT (Giữ nguyên) ---
  void addToHistory(String word) {
    if (word.trim().isEmpty) return;
    _searchHistory.remove(word);
    _searchHistory.insert(0, word);
    if (_searchHistory.length > 10) _searchHistory.removeLast();
    notifyListeners();
  }

  void removeFromHistory(String word) {
    _searchHistory.remove(word);
    notifyListeners();
  }
}