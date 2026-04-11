// lib/services/dictionary_service.dart
import '../models/word_model.dart';
import 'api_service.dart';

class DictionaryService {
  final ApiService _apiService = ApiService();

  Future<DictionaryResult?> getWordData(String word) async {
    // We change this line to use the new generic 'getRequest'
    // This calls http://10.0.2.2:5000/api/word/<your_word>
    final data = await _apiService.getRequest('/word/$word');

    if (data != null) {
      return DictionaryResult.fromJson(data);
    }
    return null;
  }
}