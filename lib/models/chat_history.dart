import 'package:cloud_firestore/cloud_firestore.dart';

class ChatHistory {
  final String id;
  final String title;
  final bool isPinned;
  final DateTime? createdAt;

  ChatHistory({
    required this.id,
    required this.title,
    this.isPinned = false,
    this.createdAt,
  });

  factory ChatHistory.fromMap(String id, Map<String, dynamic> map) {
    return ChatHistory(
      id: id,
      title: map['title'] ?? 'New Chat',
      isPinned: map['isPinned'] ?? false,
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isPinned': isPinned,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
