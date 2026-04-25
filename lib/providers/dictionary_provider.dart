import 'package:dictionary_app/services/api_service.dart';
import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/dictionary_service.dart';

class DictionaryProvider with ChangeNotifier {
  final DictionaryService _service = DictionaryService();
  
  DictionaryResult? _result;
  bool _isLoading = false;
  String? _errorMessage; 
  
  final List<String> _searchHistory = [];

  DictionaryResult? get result => _result;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage; 
  List<String> get searchHistory => _searchHistory;

  DictionaryResult? _wordOfTheDay;
  DictionaryResult? get wordOfTheDay => _wordOfTheDay;

  Future<void> fetchWordOfTheDay() async {
    try {
      // Gọi endpoint /api/words/random
      final response = await ApiService().getRequest("/words/random");
      if (response != null && response is List && response.isNotEmpty) {
        // Lấy từ WOTD trả về
        _wordOfTheDay = DictionaryResult.fromJson(response[0]);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching WOTD: $e");
    }
  }

  Future<void> searchWord(String word) async {
    _isLoading = true;
    _errorMessage = null; // Reset error
    _result = null;      // Clear old result
    notifyListeners();

    addToHistory(word);

    // Call the service
    final data = await _service.getWordData(word);

    // LOGIC FIX: Check if data is null (404 case)
    if (data == null) {
      _errorMessage = "We couldn't find definitions for '$word'";
    } else {
      _result = data;
      _errorMessage = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void addToHistory(String word) {
    if (word.trim().isEmpty) return;
    _searchHistory.remove(word);
    _searchHistory.insert(0, word);
    if (_searchHistory.length > 10) {
      _searchHistory.removeLast();
    }
    notifyListeners();
  }

  void removeFromHistory(String word) {
    _searchHistory.remove(word);
    notifyListeners();
  }
}