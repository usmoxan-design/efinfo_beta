import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPost {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String fileId; // ID from ImageKit for deletion
  final bool googleAccount;
  final bool konamiId;
  final bool gameCenter;
  final String telegramUser;
  final String phoneNumber;
  final List<String> views;
  final DateTime createdAt;

  AccountPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.fileId,
    required this.googleAccount,
    required this.konamiId,
    required this.gameCenter,
    required this.telegramUser,
    required this.phoneNumber,
    required this.views,
    required this.createdAt,
  });

  factory AccountPost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AccountPost(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Noma\'lum',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      fileId: data['fileId'] ?? '',
      googleAccount: data['googleAccount'] ?? false,
      konamiId: data['konamiId'] ?? false,
      gameCenter: data['gameCenter'] ?? false,
      telegramUser: data['telegramUser'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      views: List<String>.from(data['views'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'fileId': fileId,
      'googleAccount': googleAccount,
      'konamiId': konamiId,
      'gameCenter': gameCenter,
      'telegramUser': telegramUser,
      'phoneNumber': phoneNumber,
      'views': views,
      'createdAt':
          createdAt, // Note: MarketplaceService will handle server timestamp if needed
    };
  }
}
