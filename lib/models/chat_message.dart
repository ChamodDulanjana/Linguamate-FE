import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool hasActionButtons; // If true, show "Learn" and "Activities"
  final List<String>? learningConcepts;
  final String language;
  final DateTime? createdAt;

  ChatMessage({
    required this.text,
    this.isUser = false,
    this.hasActionButtons = false,
    this.learningConcepts,
    this.language = "en",
    this.createdAt,
  });
  
  ChatMessage copyWith({
    String? text,
    bool? isUser,
    bool? hasActionButtons,
    List<String>? learningConcepts,
    String? language,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      hasActionButtons: hasActionButtons ?? this.hasActionButtons,
      learningConcepts: learningConcepts ?? this.learningConcepts,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      hasActionButtons: map['hasActionButtons'] ?? false,
      learningConcepts: map['learningConcepts'] != null ? List<String>.from(map['learningConcepts']) : null,
      language: map['language'] ?? 'en',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'hasActionButtons': hasActionButtons,
      'learningConcepts': learningConcepts ?? [],
      'language': language,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
