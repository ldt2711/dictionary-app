import 'package:flutter/foundation.dart';
import '../models/translation_result.dart';
import '../models/translation_history.dart'; 
import 'api_service.dart';

class TranslationService {
  final ApiService _apiService = ApiService(); 

  // --- Hàm Helper: Viết hoa chữ cái đầu (vietnamese -> Vietnamese) ---
  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // --- Hàm dịch ---
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
        'session_id': userId == null ? 'user_001' : null, 
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

  // --- CẬP NHẬT: Dịch ngược mã code dựa trên Map động từ API ---
  String _getLangNameFromCode(String code, Map<String, String> langMap) {
    // Tìm trong Map cái Key nào có Value trùng với mã code (ví dụ: tìm 'vietnamese' từ 'vi')
    String? name = langMap.keys.firstWhere(
      (k) => langMap[k] == code, 
      orElse: () => code, // Nếu không thấy thì hiện mã code (ví dụ: 'af')
    );
    return _capitalize(name);
  }

  // --- CẬP NHẬT: Lấy lịch sử dịch ---
  // Thêm tham số langMap để hàm này biết cách đổi 'vi' -> 'Vietnamese' cho 100+ ngôn ngữ
  Future<List<TranslationHistory>?> getUserHistory(int userId, Map<String, String> langMap) async {
    try {
      final data = await _apiService.fetchHistory(userId: userId);
      
      if (data.isNotEmpty) {
        return data.map((json) => TranslationHistory(
          origin: json['source_text'] ?? "",
          translated: json['translated_text'] ?? "",
          
          // Sử dụng hàm tra cứu động thay vì Map cứng 10 cái như trước
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