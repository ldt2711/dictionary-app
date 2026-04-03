import 'dart:convert';
import 'package:flutter/services.dart'; // Add this for rootBundle
// import 'package:http/http.dart' as http; // Commented out for now
// import '../config/api_config.dart'; // Commented out for now

class ApiService {
  Future<dynamic> getWord(String word) async {
    
    // ==========================================
    // MOCK API LOGIC (Active)
    // ==========================================
    try {
      // 1. Load the JSON file from the assets folder
      final String response = await rootBundle.loadString('assets/mock_dictionary.json');
      
      // 2. Decode and return the data to the frontend
      return jsonDecode(response);
    } catch (e) {
      print("Error loading mock data: $e");
      return null;
    }

    // ==========================================
    // REAL API LOGIC (Commented out until ready)
    // ==========================================
    /*
    final url = "${ApiConfig.baseUrl}/dictionary/$word";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("API Error: $e");
      return null;
    }
    */
  }
}