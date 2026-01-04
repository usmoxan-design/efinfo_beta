import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'public_chat';

  // Get current user's locally stored info
  Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('chat_user_id');
    String? userName = prefs.getString('chat_user_name');

    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString('chat_user_id', userId);
    }

    // Database'dan admin holatini tekshirish
    bool isAdmin = false;
    try {
      final userDoc =
          await _firestore.collection('chat_users').doc(userId).get();
      if (userDoc.exists) {
        isAdmin = userDoc.data()?['isAdmin'] ?? false;
      }
    } catch (e) {
      debugPrint("Admin check error: $e");
    }

    if (userName != null && userName.isNotEmpty) {
      await registerUser(userId, userName);
    }

    return {
      'id': userId,
      'name': userName ?? '',
      'isAdmin': isAdmin.toString(),
    };
  }

  Future<void> saveAdminState(String userId, bool isAdmin) async {
    try {
      await _firestore.collection('chat_users').doc(userId).set({
        'isAdmin': isAdmin,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("❌ Save Admin State Error: $e");
      rethrow;
    }
  }

  // Admin holatini real-vaqtda kuzatish
  Stream<bool> getAdminStatus(String userId) {
    return _firestore
        .collection('chat_users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['isAdmin'] ?? false);
  }

  Future<void> registerUser(String userId, String name) async {
    try {
      await _firestore.collection('chat_users').doc(userId).set({
        'name': name,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("❌ Register Error: $e");
    }
  }

  Stream<int> getTotalUsersCount() {
    return _firestore
        .collection('chat_users')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('chat_user_id');
    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString('chat_user_id', userId);
    }
    await prefs.setString('chat_user_name', name);
    await registerUser(userId, name);
  }

  Stream<List<ChatMessage>> getMessages() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    });
  }

  Stream<bool> getChatStatus() {
    return _firestore
        .collection('settings')
        .doc('chat_config')
        .snapshots()
        .map((doc) => doc.data()?['isPaused'] ?? false);
  }

  Future<void> toggleChatPause(bool pause) async {
    try {
      await _firestore.collection('settings').doc('chat_config').set({
        'isPaused': pause,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("❌ Toggle Pause Error: $e");
      rethrow;
    }
  }

  Future<void> sendMessage(
      String text, String senderId, String senderName, bool isAdmin) async {
    if (text.trim().isEmpty) return;

    // Word/Character check
    if (text.length > 500) {
      throw "Xabar juda uzun! (Maks: 500 belgi)";
    }

    try {
      // Check if chat is paused (only for non-admins)
      if (!isAdmin) {
        final config =
            await _firestore.collection('settings').doc('chat_config').get();
        if (config.exists && (config.data()?['isPaused'] ?? false)) {
          throw "Hozircha xabar yuborish to'xtatilgan!";
        }
      }

      // Check if user is blocked
      final userDoc =
          await _firestore.collection('chat_users').doc(senderId).get();
      if (userDoc.exists && (userDoc.data()?['isBlocked'] ?? false)) {
        throw "Siz chatdan bloklangansiz!";
      }

      await _firestore.collection(_collectionPath).add({
        'senderId': senderId,
        'senderName': senderName,
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'views': [senderId],
        'isAdmin': isAdmin,
      });
    } catch (e) {
      debugPrint("❌ Send Error: $e");
      rethrow;
    }
  }

  Future<void> markMessageAsRead(String messageId, String userId) async {
    try {
      final docRef = _firestore.collection(_collectionPath).doc(messageId);
      await docRef.update({
        'views': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> updateMessage(String messageId, String newText) async {
    try {
      await _firestore.collection(_collectionPath).doc(messageId).update({
        'text': newText.trim(),
        'isEdited': true,
      });
    } catch (e) {
      debugPrint("❌ Update Error: $e");
      rethrow;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection(_collectionPath).doc(messageId).delete();
    } catch (e) {
      debugPrint("❌ Delete Error: $e");
      rethrow;
    }
  }

  Future<void> clearAllMessages() async {
    final snapshot = await _firestore.collection(_collectionPath).get();
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Stream<bool> getUserStatus(String userId) {
    return _firestore
        .collection('chat_users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['isBlocked'] ?? false);
  }

  Future<void> toggleUserBlock(String userId, bool block) async {
    await _firestore.collection('chat_users').doc(userId).update({
      'isBlocked': block,
    });
  }
}
