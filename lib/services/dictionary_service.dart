import '../models/word_model.dart';
import 'api_service.dart';

class DictionaryService {
  final ApiService _apiService = ApiService();

  // Change WordModel? to DictionaryResult?
  Future<DictionaryResult?> getWordData(String word) async {
    final data = await _apiService.getWord(word);

    if (data != null) {
      // Use the correct class name and the fromJson factory we just added
      return DictionaryResult.fromJson(data);
    }
    return null;
  }
}