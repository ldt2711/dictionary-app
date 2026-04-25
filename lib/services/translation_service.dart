import 'package:flutter/material.dart';
import '../models/translation_history.dart';
import '../models/translation_result.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class TranslationService {
  final ApiService _apiService = ApiService(); 

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Future<TranslationResult?> translate(
    String text, 
    String sourceLang, 
    String targetLang,
    {int? userId} 
  ) async {
    try {
      final body = {
        'text': text,
        'source_lang': sourceLang,
        'target_lang': targetLang,
        'user_id': userId, 
        'session_id': userId == null ? ApiConfig.sessionId : null, 
      };

      final data = await _apiService.postRequest('/translate', body);

      if (data != null) {
        return TranslationResult.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("Translation Error: $e"); 
      return null;
    }
  }

  String _getLangNameFromCode(String code, Map<String, String> langMap) {
    String? name = langMap.keys.firstWhere(
      (k) => langMap[k] == code, 
      orElse: () => code, 
    );
    return _capitalize(name);
  }

  Future<List<TranslationHistory>?> getUserHistory(int userId, Map<String, String> langMap) async {
    try {
      final data = await _apiService.fetchHistory(userId: userId);
      
      if (data.isNotEmpty) {
        return data.map((json) => TranslationHistory(
          origin: json['source_text'] ?? "",
          translated: json['translated_text'] ?? "",
          fromLang: _getLangNameFromCode(json['source_lang'] ?? 'en', langMap),
          toLang: _getLangNameFromCode(json['target_lang'] ?? 'vi', langMap),
          sourceAudio: json['source_audio'] ?? "",
          targetAudio: json['target_audio'] ?? "",
        )).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Lỗi Get History: $e");
      return null;
    }
  }
}