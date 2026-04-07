import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/dictionary_service.dart';

class DictionaryProvider with ChangeNotifier {
  final DictionaryService _service = DictionaryService();
  
  DictionaryResult? _result;
  bool _isLoading = false;

  // These allow the UI to "see" the data but not change it directly
  DictionaryResult? get result => _result;
  bool get isLoading => _isLoading;

  Future<void> searchWord(String word) async {
    _isLoading = true;
    notifyListeners(); // Show the loading spinner

    // Call your service (which calls your local JSON)
    _result = await _service.getWordData(word);

    _isLoading = false;
    notifyListeners(); // Hide spinner and show the word
  }
}