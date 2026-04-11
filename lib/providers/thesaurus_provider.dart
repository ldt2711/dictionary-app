import 'package:flutter/material.dart';
import '../models/thesaurus_model.dart';
import '../services/api_service.dart';

class ThesaurusProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  ThesaurusResult? _result;
  bool _isLoading = false;
  String? _errorMessage; // Tracks the 404 / Error state

  final List<String> _searchHistory = [];

  // Getters
  ThesaurusResult? get result => _result;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get searchHistory => _searchHistory;

  Future<void> searchThesaurus(String query) async {
    if (query.isEmpty) return;

    // 1. Reset state for the new search
    _isLoading = true;
    _result = null;
    _errorMessage = null; // Important: clear previous errors
    notifyListeners();

    addToHistory(query);

    try {
      final data = await _apiService.getRequest('/thesaurus/$query');

      if (data == null) {
        // Case: Backend returned 404 or null
        _errorMessage = "We couldn't find synonyms for '$query'";
      } else if (data is Map && data.containsKey('message') && data['message'] == 'Word not found') {
        // Case: Backend returned a "not found" JSON message
        _errorMessage = "We couldn't find synonyms for '$query'";
      } else {
        // Case: Success!
        _result = ThesaurusResult.fromJson(data);
        _errorMessage = null;
      }
    } catch (e) {
      // Case: Connection error or parsing crash
      _errorMessage = "Something went wrong. Please check your connection.";
      debugPrint("Thesaurus Provider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- HISTORY MANAGEMENT ---
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