import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/input_type.dart';

class ChatApiService {
  static String get baseUrl => dotenv.env['API_URL'] ?? '';

  static Future<http.StreamedResponse> sendMessage(String message, InputType inputType) async {
    final url = Uri.parse('$baseUrl/grammar-correct');

    final request = http.Request("POST", url)
    ..headers["Content-Type"] = "application/json"
    ..body = jsonEncode({
      "text": message,
      "input_type": inputType.name,
    });

    final response = await request.send();

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception("Failed to get response from server");
    }
  }

  static Future<Uri> getSentence(String text, String language) async {
    final url = Uri.parse(
      "$baseUrl/tts/sentence"
      "?text=${Uri.encodeComponent(text)}"
      "&language=$language",
    );
    return url;
  }

  static Future<Uri> getStream(String text, String language) async {
    final url = Uri.parse(
      "$baseUrl/tts/stream"
      "?text=${Uri.encodeComponent(text)}"
      "&language=$language",
    );
    return url;
  }
}
