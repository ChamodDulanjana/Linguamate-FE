import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ActivityApiService {
  static String get baseUrl => dotenv.env['API_URL'] ?? '';
  
    static Future<Map<String, dynamic>> generateActivity(
      List<String> learningConcepts, 
      String activityType, 
      String language,
    ) async {
    final url = Uri.parse('$baseUrl/generate-activity');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "learningConcepts": learningConcepts,
        "activityType": activityType,
        "language": language,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to generate activity: ${response.statusCode}");
    }
  }

}