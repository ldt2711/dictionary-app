import '../models/word_relation_model.dart';
import 'api_service.dart';

class WordRelationService {
  final ApiService _apiService = ApiService();

  Future<WordRelationResult?> getWordRelation(String query) async {
    // Gọi endpoint /thesaurus/
    final data = await _apiService.getRequest('/thesaurus/$query');

    // Kiểm tra nếu có dữ liệu và không phải là thông báo lỗi từ backend
    if (data != null && data is Map<String, dynamic> && !data.containsKey('message')) {
      return WordRelationResult.fromJson(data);
    }
    
    // Trả về null nếu không tìm thấy từ hoặc lỗi kết nối
    return null;
  }
}