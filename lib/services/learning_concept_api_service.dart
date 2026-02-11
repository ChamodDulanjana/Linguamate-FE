import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/learning_concept.dart';

class LearningConceptApiService {
  static String get baseUrl => dotenv.env['API_URL'] ?? '';

  static Future<List<LearningConcept>> fetchLearningConceptsExplanations(
    List<String> concepts, String language
  ) async {
    final url = Uri.parse('$baseUrl/learning-concept-explain');

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
      return data.map((json) => LearningConcept.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load learning concept explanations");
    }
  }
}
