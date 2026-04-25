import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;

  // Header chung để bypass Ngrok và định nghĩa kiểu dữ liệu
  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "69420", // Bypass trang cảnh báo Ngrok
      };

  // 1. FOR GET REQUESTS
  // Asking the server for infomation
  Future<dynamic> getRequest(String endpoint) async {
    try {
      final url = Uri.parse("$baseUrl$endpoint");
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("GET Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Connection failed (GET): $e");
      return null;
    }
  }

  // 2. FOR POST REQUESTS
  // Sending data to server
  Future<dynamic> postRequest(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse("$baseUrl$endpoint");
      final response = await http.post(
        url,
        headers: _headers, // Đã thêm header bypass ngrok vào đây
        body: jsonEncode(body),
      );

      // Thường Flask trả về 200 hoặc 201 cho thành công
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        // Trả về body lỗi từ server (ví dụ: "Username already exists")
        if (response.body.isNotEmpty) {
          try {
            return jsonDecode(response.body);
          } catch (_) {
            return {"error": response.body};
          }
        }
        return null;
      }
    } catch (e) {
      print("POST Connection failed: $e");
      return null;
    }
  }

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
    // Sử dụng Uri.http hoặc cộng chuỗi an toàn hơn
    Map<String, String> queryParams = {};
    if (userId != null) queryParams['user_id'] = userId.toString();
    if (sessionId != null) queryParams['session_id'] = sessionId;

    String queryString = Uri(queryParameters: queryParams).query;
    String endpoint = "/history${queryString.isNotEmpty ? '?$queryString' : ''}";

    final result = await getRequest(endpoint);
    return result is List ? result : [];
  }
  
  // 7. LẤY DANH SÁCH NGÔN NGỮ
  Future<Map<String, String>> fetchLanguages() async {
    final result = await getRequest("/languages");
    print("DEBUG: Language Result = $result");
    if (result != null) {
      return Map<String, String>.from(result);
    }
    return {}; 
  }
}