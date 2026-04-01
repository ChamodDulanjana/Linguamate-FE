import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../models/chat_history.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Create a new chat session
  Future<String> createChatSession(String userId, String firstMessageText) async {
    // Make chat title unique and well-formatted
    String baseName = firstMessageText.trim();
    if (baseName.length > 20) {
      baseName = '${baseName.substring(0, 20)}...';
    }
    // Capitalize first letter for a proper look
    if (baseName.isNotEmpty) {
      baseName = baseName[0].toUpperCase() + baseName.substring(1);
    }
    
    // Add a date/time stamp to assure uniqueness
    final now = DateTime.now();
    final timeString = '${now.month}/${now.day} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    
    String title = '$baseName - $timeString';

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
      final allChats = snapshot.docs.map((doc) => ChatHistory.fromMap(doc.id, doc.data())).toList();
      
      final pinnedChats = allChats.where((chat) => chat.isPinned).toList();
      final unpinnedChats = allChats.where((chat) => !chat.isPinned).toList();
      
      return [...pinnedChats, ...unpinnedChats];
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

  // 5. Delete a chat
  Future<void> deleteChat(String userId, String chatId) async {
    final messages = await _db
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();
        
    for (var doc in messages.docs) {
      await doc.reference.delete();
    }
    
    await _db
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .delete();
  }

  // 6. Pin/Unpin a chat
  Future<void> togglePinStatus(String userId, String chatId, bool currentStatus) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .update({
      'isPinned': !currentStatus,
    });
  }
}
