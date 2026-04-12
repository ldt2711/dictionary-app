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

  Future<void> fetchWordOfTheDay() async {
    if (_result != null) return; 
    
    _isLoading = true;
    notifyListeners();

    _result = await _service.getWordData("serendipity"); 

    _isLoading = false;
    notifyListeners();
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