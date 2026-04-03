import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_api_service.dart';
class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(User user) async {
    await _db.collection("users").doc(user.uid).set({
      "uid": user.uid,
      "email": user.email,
      "name": user.displayName ?? user.email!.split('@').first,
      "createdAt": DateTime.now(),
    }, SetOptions(merge: true));
  }

  Future<bool> checkEmailExists(String email) async {
    final snapshot = await _db
        .collection("users")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> updateUserVoice(String uid, String voiceType) async {
    // Uptade user voice locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_voice_$uid', voiceType);

    // Uptade user voice in firebase
    await _db.collection("users").doc(uid).set({
      "voice_type": voiceType,
    }, SetOptions(merge: true));
  }

  Future<String> getUserVoice(String uid) async {
    // Get user voice from local storage
    final prefs = await SharedPreferences.getInstance();
    final cachedVoice = prefs.getString('user_voice_$uid');
    
    if (cachedVoice != null && cachedVoice.isNotEmpty) {
      return cachedVoice;
    }

    // Get user voice from firebase if not found in local storage
    final doc = await _db.collection("users").doc(uid).get();
    if (doc.exists && doc.data()!.containsKey("voice_type")) {
      final serverVoice = doc.data()!["voice_type"];
      // Save user voice in local storage
      await prefs.setString('user_voice_$uid', serverVoice);
      // Return user voice
      return serverVoice;
    }
    // Return default voice if not found in local storage or firebase
    return "alloy";
  }

  Future<Uri> getVoicePreviewUri(String uid, String voiceType) async {
    final docRef = _db.collection("voicePreviews").doc(voiceType);
    final doc = await docRef.get();
    
    if (doc.exists && doc.data()!.containsKey("uri")) {
      final cachedPath = doc.data()!["uri"] as String;
      final file = File(cachedPath);
      if (await file.exists()) {
        return Uri.file(cachedPath);
      }
    }

    final sentence = "Hi, I am your Linguamate voice assistant.";
    final backendUri = await ChatApiService.getSentence(sentence, "en", voiceType);

    final response = await http.get(backendUri);
    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/preview_$voiceType.mp3');
      await file.writeAsBytes(response.bodyBytes);
      
      await docRef.set({
        "voice_input": voiceType,
        "sentence": sentence,
        "uri": file.path,
      }, SetOptions(merge: true));

      return Uri.file(file.path);
    } else {
      return backendUri;
    }
  }
}