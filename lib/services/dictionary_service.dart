// lib/services/dictionary_service.dart
import '../models/word_model.dart';
import 'api_service.dart';

class DictionaryService {
  final ApiService _apiService = ApiService();

  Future<DictionaryResult?> getWordData(String word) async {
 
    final data = await _apiService.getRequest('/word/$word');

    if (data != null) {
      return DictionaryResult.fromJson(data);
    }
    return null;
  }
}