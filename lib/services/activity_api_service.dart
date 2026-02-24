import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

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

  static Future<Map<String, dynamic>> evaluateSpeaking(
    String filePath,
    String targetSentence,
    String language,
  ) async {
    final dio = Dio();
    final url = '$baseUrl/speaking/evaluate';

    try {
      FormData formData = FormData.fromMap({
        "audio": await MultipartFile.fromFile(
          filePath,
          filename: 'audio.m4a',
          contentType: MediaType('audio', 'm4a'),
        ),
        "targetSentence": targetSentence,
        "language": language,
      });

      final response = await dio.post(
        url,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          "Failed to evaluate speaking: ${response.statusMessage}",
        );
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data != null
          ? e.response?.data.toString()
          : e.message;
      throw Exception("Dio Error: $errorMsg");
    } catch (e) {
      throw Exception("Unexpected Error: $e");
    }
  }
}
