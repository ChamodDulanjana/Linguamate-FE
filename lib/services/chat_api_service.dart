import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatApiService {
  static String get baseUrl => dotenv.env['API_URL'] ?? '';

  static Future<Map<String, dynamic>> sendMessage(String message) async {
    final url = Uri.parse('$baseUrl/grammar-correct');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"text": message}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to get response from server");
    }
  }
}
