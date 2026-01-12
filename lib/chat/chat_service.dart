import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionPath = 'public_chat';

  // Get current user's Firebase info
  Future<Map<String, String>> getUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {
        'id': '',
        'name': '',
        'isAdmin': 'false',
      };
    }

    final userId = user.uid;
    final userName = user.displayName ?? '';

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

    return {
      'id': userId,
      'name': userName,
      'isAdmin': isAdmin.toString(),
      'email': user.email ?? '',
    };
  }

  Future<Map<String, String>> getUserInfoByOtherId(String userId) async {
    try {
      final userDoc =
          await _firestore.collection('chat_users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        return {
          'id': userId,
          'name': data?['name'] ?? 'Noma\'lum',
          'isAdmin': (data?['isAdmin'] ?? false).toString(),
        };
      }
    } catch (e) {
      debugPrint("Get user info error: $e");
    }
    return {
      'id': userId,
      'name': 'Noma\'lum',
      'isAdmin': 'false',
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
    if (userId.isEmpty) return Stream.value(false);
    return _firestore
        .collection('chat_users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['isAdmin'] ?? false);
  }

  Future<bool> checkIfAdmin(String userId) async {
    if (userId.isEmpty) return false;
    try {
      final doc = await _firestore.collection('chat_users').doc(userId).get();
      return doc.data()?['isAdmin'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> registerUser(String userId, String name, {String? email}) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'lastSeen': FieldValue.serverTimestamp(),
      };
      if (email != null) data['email'] = email;

      await _firestore
          .collection('chat_users')
          .doc(userId)
          .set(data, SetOptions(merge: true));
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
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await registerUser(user.uid, name, email: user.email);
    }
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
      String text, String senderId, String senderName, bool isAdmin,
      {String? replyToId,
      String? replyToName,
      String? replyToText,
      String? replyToSenderId}) async {
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
        'replyToId': replyToId,
        'replyToName': replyToName,
        'replyToText': replyToText,
        'replyToSenderId': replyToSenderId,
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

  Future<void> updateMessage(
    String messageId,
    String newText,
  ) async {
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
