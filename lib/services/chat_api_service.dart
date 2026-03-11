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

  // static Future<Map<String, dynamic>> sendMessage(String message, InputType inputType) async {
  //   final url = Uri.parse('$baseUrl/grammar-correct');
  //   print("Sending message to backend: $message");
  //   print("Input type: ${inputType.name}");

  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({"text": message, "input_type": inputType.name}),
  //   );

  //   if (response.statusCode == 200) {
  //     final decodedResponse = jsonDecode(response.body);
  //     return {
  //       "response": decodedResponse["response"],
  //       "language": decodedResponse["language"],
  //       "hasActionButtons": decodedResponse["hasActionButtons"] ?? false,
  //       "learningConcepts": decodedResponse["learningConcepts"] != null
  //           ? List<String>.from(decodedResponse["learningConcepts"])
  //           : null,
  //       "voiceEnabled": decodedResponse["voiceEnabled"] ?? false,
  //     };
  //   } else {
  //     throw Exception("Failed to get response from server");
  //   }
  // }
}
