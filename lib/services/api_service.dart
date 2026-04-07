import 'dart:convert';
import 'package:flutter/services.dart'; // Required for rootBundle
// import 'package:http/http.dart' as http; 
// import '../config/api_config.dart';

class ApiService {
  
  // ==========================================
  // DICTIONARY METHODS
  // ==========================================
  Future<dynamic> getWord(String word) async {
    // --- MOCK LOGIC ---
    try {
      final String response = await rootBundle.loadString('assets/mock_dictionary.json');
      return jsonDecode(response);
    } catch (e) {
      print("Error loading dictionary mock: $e");
      return null;
    }

    // --- REAL API LOGIC (Uncomment when backend is ready) ---
    /*
    final url = "${ApiConfig.baseUrl}/dictionary/$word";
    final response = await http.get(Uri.parse(url));
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
    */
  }

  // ==========================================
  // THESAURUS METHODS
  // ==========================================
  Future<dynamic> getThesaurus(String word) async {
    // --- MOCK LOGIC ---
    try {
      // Pointing to your NEW thesaurus JSON file
      final String response = await rootBundle.loadString('assets/mock_thesaurus.json');
      return jsonDecode(response);
    } catch (e) {
      print("Error loading thesaurus mock: $e");
      return null;
    }

    // --- REAL API LOGIC (Uncomment when backend is ready) ---
    /*
    final url = "${ApiConfig.baseUrl}/thesaurus/$word";
    final response = await http.get(Uri.parse(url));
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
    */
  }
}