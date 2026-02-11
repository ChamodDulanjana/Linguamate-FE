import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/grammar_data.dart';

class GrammarApiService {
  static String get baseUrl => dotenv.env['API_URL'] ?? '';

  static Future<List<GrammarRule>> fetchGrammarExplanations(
    List<String> concepts, String language
  ) async {
    final url = Uri.parse('$baseUrl/grammar-explain');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "learningConcepts": concepts,
        "language": language,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GrammarRule.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load grammar explanations");
    }
  }
}
