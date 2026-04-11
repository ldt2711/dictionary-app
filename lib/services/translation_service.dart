import 'package:flutter/foundation.dart';
import '../models/translation_result.dart';
import '../models/translation_history.dart'; 
import 'api_service.dart';

class TranslationService {
  final ApiService _apiService = ApiService(); 

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

  // --- HÀM MỚI: Dịch ngược mã code từ Database (vi, en, fr...) thành Tên ngôn ngữ để hiển thị ---
  String _getLangNameFromCode(String code) {
    const Map<String, String> codeToName = {
      'vi': 'Tiếng Việt',
      'en': 'English',
      'fr': 'Français (Pháp)',
      'ja': '日本語 (Nhật)',
      'ko': '한국어 (Hàn)',
      'zh-CN': '中文 (Trung)',
      'es': 'Español (Tây Ban Nha)',
      'de': 'Deutsch (Đức)',
      'ru': 'Русский (Nga)',
      'th': 'ภาษาไทย (Thái)'
    };
    return codeToName[code] ?? 'English'; // Trả về English nếu gặp mã lạ
  }

  // --- Hàm lấy lịch sử dịch của User ---
  Future<List<TranslationHistory>?> getUserHistory(int userId) async {
    try {
      // Gọi API lấy lịch sử từ Flask
      final data = await _apiService.fetchHistory(userId: userId);
      
      // Nếu có dữ liệu, chuyển JSON thành List<TranslationHistory>
      if (data.isNotEmpty) {
        return data.map((json) => TranslationHistory(
          origin: json['source_text'] ?? "",
          translated: json['translated_text'] ?? "",
          
          // CẬP NHẬT Ở ĐÂY: Sử dụng hàm _getLangNameFromCode để hiển thị đúng ngôn ngữ
          fromLang: _getLangNameFromCode(json['source_lang'] ?? 'en'),
          toLang: _getLangNameFromCode(json['target_lang'] ?? 'vi'),
          
          sourceAudio: json['source_audio'] ?? "",
          targetAudio: json['target_audio'] ?? "",
        )).toList();
      }
      return []; // Trả về mảng rỗng nếu chưa có lịch sử
    } catch (e) {
      debugPrint("Lỗi Get History: $e");
      return null;
    }
  }
}