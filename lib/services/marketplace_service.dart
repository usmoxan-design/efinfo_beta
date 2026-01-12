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
  Future<void> addPost(AccountPost post, List<File> imageFiles) async {
    try {
      List<String> imageUrls = [];
      List<String> fileIds = [];

      // 1. Upload all to ImageKit
      for (var imageFile in imageFiles) {
        String fileName =
            "account_${DateTime.now().millisecondsSinceEpoch}_${imageFiles.indexOf(imageFile)}.jpg";
        var uploadResult =
            await ImageKitService.uploadImage(imageFile, fileName);

        if (uploadResult == null) {
          // If one fails, we might want to cleanup others, but for simplicity:
          throw "Rasm yuklashda xatolik yuz berdi (ImageKit)";
        }

        imageUrls.add(uploadResult['url']);
        fileIds.add(uploadResult['fileId']);
      }

      // 2. Save post to Firestore
      Map<String, dynamic> postData = post.toFirestore();

      // Check for admin status to add badge
      bool isAdmin = false;
      try {
        final userDoc =
            await _firestore.collection('chat_users').doc(post.userId).get();
        isAdmin = userDoc.data()?['isAdmin'] ?? false;
      } catch (_) {}

      postData['imageUrls'] = imageUrls;
      postData['fileIds'] = fileIds;
      postData['isAuthorAdmin'] = isAdmin;
      postData['createdAt'] = FieldValue.serverTimestamp();

      // Clear legacy fields if they were set in toFirestore
      postData.remove('imageUrl');
      postData.remove('fileId');

      await _firestore.collection(_collectionPath).add(postData);
    } catch (e) {
      debugPrint("Add post error: $e");
      rethrow;
    }
  }

  // Update a post
  Future<void> updatePost(AccountPost post, List<File>? newImageFiles) async {
    try {
      List<String> imageUrls = post.imageUrls;
      List<String> fileIds = post.fileIds;

      // 1. Update images if new ones provided
      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        // Delete OLD images from ImageKit
        for (var fId in post.fileIds) {
          if (fId.isNotEmpty) {
            await ImageKitService.deleteImage(fId);
          }
        }

        imageUrls = [];
        fileIds = [];

        // Upload NEW images
        for (var imageFile in newImageFiles) {
          String fileName =
              "account_${DateTime.now().millisecondsSinceEpoch}_${newImageFiles.indexOf(imageFile)}.jpg";
          var uploadResult =
              await ImageKitService.uploadImage(imageFile, fileName);
          if (uploadResult == null)
            throw "Yangi rasm yuklashda xatolik yuz berdi";

          imageUrls.add(uploadResult['url']);
          fileIds.add(uploadResult['fileId']);
        }
      }

      // 2. Update Firestore doc
      Map<String, dynamic> postData = post.toFirestore();

      // Refresh admin status
      bool isAdmin = false;
      try {
        final userDoc =
            await _firestore.collection('chat_users').doc(post.userId).get();
        isAdmin = userDoc.data()?['isAdmin'] ?? false;
      } catch (_) {}

      postData['imageUrls'] = imageUrls;
      postData['fileIds'] = fileIds;
      postData['isAuthorAdmin'] = isAdmin;

      // Don't overwrite original creation date
      postData.remove('createdAt');
      postData.remove('imageUrl');
      postData.remove('fileId');

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
  Future<void> deletePost(String postId, List<String> fileIds) async {
    try {
      // 1. Delete Firestore doc
      await _firestore.collection(_collectionPath).doc(postId).delete();

      // 2. Delete images from ImageKit
      for (var fileId in fileIds) {
        if (fileId.isNotEmpty) {
          await ImageKitService.deleteImage(fileId);
        }
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
