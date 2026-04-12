import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Lưu ý: 
  // - Dùng 10.0.2.2 nếu bạn chạy Android Emulator.
  // - Dùng 127.0.0.1 nếu chạy Web hoặc iOS Simulator.
  final String baseUrl = "http://127.0.0.1:5000/api";

  // 1. FOR GET REQUESTS
  Future<dynamic> getRequest(String endpoint) async {
    try {
      final url = Uri.parse("$baseUrl$endpoint");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Server Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Connection failed: $e");
      return null;
    }
  }

  // 2. FOR POST REQUESTS
  Future<dynamic> postRequest(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse("$baseUrl$endpoint");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        print("POST Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("POST Connection failed: $e");
      return null;
    }
  }

  // ============================================================
  // CÁC HÀM AUTH & HISTORY
  // ============================================================

  // 3. ĐĂNG NHẬP
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final result = await postRequest("/login", {
      "username": username, 
      "password": password
    });
    return result;
  }

  // 4. ĐĂNG KÝ
  Future<Map<String, dynamic>?> register(String username, String password) async {
    final result = await postRequest("/register", {
      "username": username, 
      "password": password
    });
    return result;
  }

  // 5. ĐỒNG BỘ LỊCH SỬ
  Future<bool> mergeHistory(int userId, String sessionId) async {
    final result = await postRequest("/merge-history", {
      "user_id": userId,
      "session_id": sessionId
    });
    
    return result != null && result['message'] == "Merge success";
  }

  // 6. LẤY LỊCH SỬ
  Future<List<dynamic>> fetchHistory({int? userId, String? sessionId}) async {
    String endpoint = "/history?";
    if (userId != null) {
      endpoint += "user_id=$userId";
    } else if (sessionId != null) {
      endpoint += "session_id=$sessionId";
    }

    final result = await getRequest(endpoint);
    return result ?? [];
  }

  // ============================================================
  // MỚI: HÀM LẤY DANH SÁCH NGÔN NGỮ ĐỘNG
  // ============================================================
  
  // 7. LẤY DANH SÁCH NGÔN NGỮ (Từ Google Translator qua Flask)
  Future<Map<String, String>> fetchLanguages() async {
    final result = await getRequest("/languages");
    if (result != null) {
      // Ép kiểu dynamic sang Map<String, String> một cách an toàn
      return Map<String, String>.from(result);
    }
    return {}; // Trả về Map rỗng nếu có lỗi để app không bị crash
  }
}