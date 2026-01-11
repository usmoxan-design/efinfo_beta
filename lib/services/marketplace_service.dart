import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:efinfo_beta/models/account_post.dart';
import 'package:efinfo_beta/services/imagekit_service.dart';
import 'package:flutter/foundation.dart';

class MarketplaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'account_marketplace';

  // Get all posts
  Stream<List<AccountPost>> getPosts() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AccountPost.fromFirestore(doc))
          .toList();
    });
  }

  // Get user's post count
  Future<int> getUserPostCount(String userId) async {
    final query = await _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .get();
    return query.docs.length;
  }

  // Add a new post
  Future<void> addPost(AccountPost post, File imageFile) async {
    try {
      // 1. Upload to ImageKit
      String fileName = "account_${DateTime.now().millisecondsSinceEpoch}.jpg";
      var uploadResult = await ImageKitService.uploadImage(imageFile, fileName);

      if (uploadResult == null)
        throw "Rasm yuklashda xatolik yuz berdi (ImageKit)";

      String imageUrl = uploadResult['url'];
      String fileId = uploadResult['fileId'];

      // 2. Save post to Firestore
      Map<String, dynamic> postData = post.toFirestore();
      postData['imageUrl'] = imageUrl;
      postData['fileId'] = fileId;
      postData['createdAt'] = FieldValue.serverTimestamp();

      await _firestore.collection(_collectionPath).add(postData);
    } catch (e) {
      debugPrint("Add post error: $e");
      rethrow;
    }
  }

  // Update a post
  Future<void> updatePost(AccountPost post, File? newImageFile) async {
    try {
      String imageUrl = post.imageUrl;
      String fileId = post.fileId;

      // 1. Update image if new one provided
      if (newImageFile != null) {
        // Delete old image from ImageKit
        if (post.fileId.isNotEmpty) {
          await ImageKitService.deleteImage(post.fileId);
        }

        // Upload new image
        String fileName =
            "account_${DateTime.now().millisecondsSinceEpoch}.jpg";
        var uploadResult =
            await ImageKitService.uploadImage(newImageFile, fileName);
        if (uploadResult == null)
          throw "Yangi rasm yuklashda xatolik yuz berdi";

        imageUrl = uploadResult['url'];
        fileId = uploadResult['fileId'];
      }

      // 2. Update Firestore doc
      Map<String, dynamic> postData = post.toFirestore();
      postData['imageUrl'] = imageUrl;
      postData['fileId'] = fileId;

      // Don't overwrite original creation date
      postData.remove('createdAt');

      await _firestore
          .collection(_collectionPath)
          .doc(post.id)
          .update(postData);
    } catch (e) {
      debugPrint("Update post error: $e");
      rethrow;
    }
  }

  // Delete a post
  Future<void> deletePost(String postId, String fileId) async {
    try {
      // 1. Delete Firestore doc
      await _firestore.collection(_collectionPath).doc(postId).delete();

      // 2. Delete image from ImageKit
      if (fileId.isNotEmpty) {
        await ImageKitService.deleteImage(fileId);
      }
    } catch (e) {
      debugPrint("Delete post error: $e");
      rethrow;
    }
  }

  // Increment view count
  Future<void> incrementView(String postId, String userId) async {
    try {
      await _firestore.collection(_collectionPath).doc(postId).update({
        'views': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      debugPrint("Increment view error: $e");
    }
  }
}
