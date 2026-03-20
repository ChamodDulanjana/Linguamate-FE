import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../models/chat_history.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Create a new chat session
  Future<String> createChatSession(String userId, String firstMessageText) async {
    String title = firstMessageText.length > 25 
        ? '${firstMessageText.substring(0, 25)}...' 
        : firstMessageText;

    final docRef = await _db.collection('users').doc(userId).collection('chats').add({
      'title': title,
      'isPinned': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // 2. Save a message to an existing chat
  Future<void> saveMessage(String userId, String chatId, ChatMessage message) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
  }

  // 3. Listen to users chats (for the drawer)
  Stream<List<ChatHistory>> getUserChats(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('chats')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatHistory.fromMap(doc.id, doc.data())).toList();
    });
  }

  // 4. Load messages for a chat screen
  Future<List<ChatMessage>> getChatMessages(String userId, String chatId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data())).toList();
  }
}
