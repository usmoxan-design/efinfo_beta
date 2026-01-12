import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPost {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final double price;
  final List<String> imageUrls;
  final List<String> fileIds; // IDs from ImageKit for deletion
  final bool googleAccount;
  final bool konamiId;
  final bool gameCenter;
  final String telegramUser;
  final String phoneNumber;
  final List<String> views;
  final DateTime createdAt;
  final bool isAuthorAdmin;
  final bool isExchange;

  AccountPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.fileIds,
    required this.googleAccount,
    required this.konamiId,
    required this.gameCenter,
    required this.telegramUser,
    required this.phoneNumber,
    required this.views,
    required this.createdAt,
    this.isAuthorAdmin = false,
    this.isExchange = false,
  });

  factory AccountPost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Legacy support for single image
    List<String> imageUrls = [];
    if (data['imageUrls'] != null) {
      imageUrls = List<String>.from(data['imageUrls']);
    } else if (data['imageUrl'] != null) {
      imageUrls = [data['imageUrl']];
    }

    List<String> fileIds = [];
    if (data['fileIds'] != null) {
      fileIds = List<String>.from(data['fileIds']);
    } else if (data['fileId'] != null) {
      fileIds = [data['fileId']];
    }

    return AccountPost(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Noma\'lum',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrls: imageUrls,
      fileIds: fileIds,
      googleAccount: data['googleAccount'] ?? false,
      konamiId: data['konamiId'] ?? false,
      gameCenter: data['gameCenter'] ?? false,
      telegramUser: data['telegramUser'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      views: List<String>.from(data['views'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAuthorAdmin: data['isAuthorAdmin'] ?? false,
      isExchange: data['isExchange'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'title': title,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'fileIds': fileIds,
      'googleAccount': googleAccount,
      'konamiId': konamiId,
      'gameCenter': gameCenter,
      'telegramUser': telegramUser,
      'phoneNumber': phoneNumber,
      'views': views,
      'createdAt': createdAt,
      'isAuthorAdmin': isAuthorAdmin,
      'isExchange': isExchange,
    };
  }

  // Helper to get first image
  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';
  String get fileId => fileIds.isNotEmpty ? fileIds.first : '';
}
