import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator
  // Use 127.0.0.1 for iOS Simulator
  final String baseUrl = "http://127.0.0.1:5000/api";
  // 1. FOR GET REQUESTS (Dictionary & Thesaurus)
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

  // 2. FOR POST REQUESTS (Translation, Login, Register)
  // This matches your successful Postman test!
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
        print("POST Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("POST Connection failed: $e");
      return null;
    }
  }
}