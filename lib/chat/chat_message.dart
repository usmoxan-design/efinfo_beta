import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final List<String> views;
  final bool isAdmin;
  final String? replyToId;
  final String? replyToName;
  final String? replyToText;
  final String? replyToSenderId;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.views = const [],
    this.isAdmin = false,
    this.replyToId,
    this.replyToName,
    this.replyToText,
    this.replyToSenderId,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Anonim',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      views: List<String>.from(data['views'] ?? []),
      isAdmin: data['isAdmin'] ?? false,
      replyToId: data['replyToId'],
      replyToName: data['replyToName'],
      replyToText: data['replyToText'],
      replyToSenderId: data['replyToSenderId'],
    );
  }
}
