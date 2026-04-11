import 'package:flutter/material.dart';
import '../models/thesaurus_model.dart';
import '../services/api_service.dart';

class ThesaurusProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  ThesaurusResult? _result;
  bool _isLoading = false;
  
  // --- THÊM LỊCH SỬ TÌM KIẾM ---
  final List<String> _searchHistory = [];

  ThesaurusResult? get result => _result;
  bool get isLoading => _isLoading;
  List<String> get searchHistory => _searchHistory;

  Future<void> searchThesaurus(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _result = null; 
    notifyListeners();

    // Thêm vào lịch sử
    addToHistory(query);

    try {
      final data = await _apiService.getRequest('/thesaurus/$query');

      if (data != null) {
        if (data.containsKey('message') && data['message'] == 'Word not found') {
           _result = ThesaurusResult(word: query, synonyms: [], antonyms: [], relatedPhrases: []);
        } else {
           _result = ThesaurusResult.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint("Thesaurus Provider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- HÀM QUẢN LÝ LỊCH SỬ ---
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