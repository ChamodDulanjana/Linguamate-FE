import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApiService {
  // Use 10.0.2.2 for Android Emulator
  // Use your PC IP for real phone (e.g. 192.168.1.54)
  static const String baseUrl = "http://10.0.2.2:8000";

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
