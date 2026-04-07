import 'package:flutter/material.dart';
import '../models/thesaurus_model.dart';
import '../services/api_service.dart'; // 1. Import your API Service

class ThesaurusProvider extends ChangeNotifier {
  // 2. Create an instance of the ApiService
  final ApiService _apiService = ApiService();

  ThesaurusResult? _result;
  bool _isLoading = false;

  ThesaurusResult? get result => _result;
  bool get isLoading => _isLoading;

  void hide() {
    _result = null;
    notifyListeners();
  }

  Future<void> searchThesaurus(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _result = null; 
    notifyListeners();

    try {
      // 3. Call the actual service method we created
      final data = await _apiService.getThesaurus(query);

      if (data != null) {
        // 4. Map the raw JSON data to your model
        _result = ThesaurusResult.fromJson(data);
      } else {
        _result = null;
      }
    } catch (e) {
      debugPrint("Thesaurus Provider Error: $e");
      _result = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}