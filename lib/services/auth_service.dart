import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listen to auth changes
  Stream<User?> get user => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      debugPrint("Login error: $e");
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUp(String email, String password, String name,
      {Map<String, dynamic>? deviceInfo}) async {
    try {
      // Check if name is already taken (Commented out due to security rules requiring auth)
      /* 
      final nameCheck = await _firestore
          .collection('chat_users')
          .where('name', isEqualTo: name)
          .get();
      if (nameCheck.docs.isNotEmpty) {
        throw "Bu ism band, boshqa ism tanlang!";
      }
      */

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Update user display name
      await credential.user?.updateDisplayName(name);

      // Save user to firestore
      await _firestore.collection('chat_users').doc(credential.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false,
        'isBlocked': false,
        'coins': 200, // Starting balance
        if (deviceInfo != null) 'deviceInfo': deviceInfo,
      }, SetOptions(merge: true));

      return credential;
    } catch (e) {
      debugPrint("Signup error: $e");
      rethrow;
    }
  }

  // Get current user's coin balance stream
  Stream<int> getUserCoins(String userId) {
    return _firestore
        .collection('chat_users')
        .doc(userId)
        .snapshots()
        .map((snap) => snap.data()?['coins'] ?? 0);
  }

  // Get current user's coins once
  Future<int> getCurrentUserCoins() async {
    if (currentUser == null) return 0;
    final doc =
        await _firestore.collection('chat_users').doc(currentUser!.uid).get();
    return doc.data()?['coins'] ?? 0;
  }

  // Update coins
  Future<void> updateUserCoins(String userId, int amount) async {
    await _firestore.collection('chat_users').doc(userId).update({
      'coins': FieldValue.increment(amount),
    });
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
