import 'package:flutter/foundation.dart'; // <--- ADD THIS IMPORT
import '../models/translation_result.dart';
import 'api_service.dart';

class TranslationService {
  final ApiService _apiService = ApiService(); 

  Future<TranslationResult?> translate(
    String text, 
    String sourceLang, 
    String targetLang,
  ) async {
    try {
      final body = {
        'text': text,
        'source_lang': sourceLang,
        'target_lang': targetLang,
        'session_id': 'user_001', 
      };

      final data = await _apiService.postRequest('/translate', body);

      if (data != null) {
        return TranslationResult.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("Translation Error: $e"); // Now this will work!
      return null;
    }
  }
}