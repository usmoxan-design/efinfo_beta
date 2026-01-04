import 'package:efinfo_beta/chat/chat_message.dart';
import 'package:efinfo_beta/chat/chat_service.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _myId;
  String? _myName;
  bool _isLoading = true;
  bool _isAdmin = false;
  bool _isChatPaused = false;
  final Set<String> _readMessages = {};

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final info = await _chatService.getUserInfo();
    setState(() {
      _myId = info['id'];
      _myName = info['name'];
      _isAdmin = info['isAdmin'] == 'true';
      _isLoading = false;
    });

    if (_myName == null || _myName!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNameDialog();
      });
    }
  }

  void _showNameDialog() {
    final TextEditingController nameController =
        TextEditingController(text: _myName);
    showDialog(
      context: context,
      barrierDismissible: _myName != null && _myName!.isNotEmpty,
      builder: (context) {
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surface : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Ismingizni kiriting",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Ism...",
              hintStyle: GoogleFonts.outfit(color: Colors.grey),
              filled: true,
              fillColor:
                  isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: GoogleFonts.outfit(),
          ),
          actions: [
            if (_myName != null && _myName!.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Bekor qilish",
                  style: GoogleFonts.outfit(color: Colors.grey),
                ),
              ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  await _chatService.saveUserName(nameController.text.trim());
                  setState(() {
                    _myName = nameController.text.trim();
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(
                "Saqlash",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF06DF5D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAdminLoginDialog() {
    final TextEditingController passController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surface : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Admin Kirish",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: passController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Parol...",
              filled: true,
              fillColor:
                  isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Bekor qilish",
                  style: GoogleFonts.outfit(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                if (passController.text == "Usmonjon2003") {
                  if (_myId != null) {
                    await _chatService.saveAdminState(_myId!, true);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Siz endi Adminsiz! ✅")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Parol noto'g'ri! ❌")),
                  );
                }
              },
              child: Text("Kirish",
                  style: GoogleFonts.outfit(
                      color: const Color(0xFF06DF5D),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_myName == null || _myName!.isEmpty) {
      _showNameDialog();
      return;
    }

    final text = _messageController.text.trim();
    _messageController.clear();

    try {
      await _chatService.sendMessage(text, _myId!, _myName!, _isAdmin);
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (_isLoading) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF06DF5D))),
      );
    }

    return StreamBuilder<bool>(
      stream: _myId != null
          ? _chatService.getAdminStatus(_myId!)
          : Stream.value(false),
      builder: (context, adminSnap) {
        _isAdmin = adminSnap.data ?? _isAdmin; // Update local state from stream

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ommaviy Chat",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      StreamBuilder<int>(
                        stream: _chatService.getTotalUsersCount(),
                        builder: (context, snapshot) {
                          return Text(
                            "${snapshot.data ?? 0} a'zo",
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: const Color(0xFF06DF5D),
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (_isAdmin) ...[
                    StreamBuilder<bool>(
                      stream: _chatService.getChatStatus(),
                      builder: (context, snapshot) {
                        final isPaused = snapshot.data ?? false;
                        return IconButton(
                          onPressed: () =>
                              _chatService.toggleChatPause(!isPaused),
                          icon: Icon(
                            isPaused
                                ? Icons.play_circle_fill
                                : Icons.pause_circle_filled,
                            color:
                                isPaused ? const Color(0xFF06DF5D) : Colors.red,
                          ),
                          tooltip: isPaused
                              ? "Chatni davom ettirish"
                              : "Chatni to'xtatish",
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Chatni tozalash?"),
                            content: const Text(
                                "Barcha xabarlar o'chirib tashlanadi!"),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Yo'q")),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child:
                                      const Text("Ha, barchasini o'chirish")),
                            ],
                          ),
                        );
                        if (confirm == true)
                          await _chatService.clearAllMessages();
                      },
                      icon:
                          const Icon(Icons.delete_sweep, color: Colors.orange),
                      tooltip: "Chatni tozalash",
                    ),
                    GestureDetector(
                      onLongPress: _showAdminLoginDialog,
                      child: TextButton.icon(
                        onPressed: _showNameDialog,
                        icon: const Icon(
                          Icons.edit_note,
                          size: 20,
                          color: Color(0xFF06DF5D),
                        ),
                        label: Text(
                          "Ismni o'zgartirish",
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ]),
              ),

              // Messages List
              Expanded(
                child: StreamBuilder<List<ChatMessage>>(
                  stream: _chatService.getMessages(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                          child: Text("Xatolik yuz berdi: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF06DF5D)));
                    }

                    final messages = snapshot.data!;
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          "Hozircha xabarlar yo'q.\nBirinchi bo'lib yozing!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == _myId;

                        // Mark as read logic
                        if (!isMe &&
                            _myId != null &&
                            !message.views.contains(_myId) &&
                            !_readMessages.contains(message.id)) {
                          _readMessages.add(message.id);
                          _chatService.markMessageAsRead(message.id, _myId!);
                        }

                        return _buildMessageBubble(message, isMe, isDark);
                      },
                    );
                  },
                ),
              ),

              // Input Area
              _buildInputArea(true, isDark),
              const SizedBox(height: 100), // Bottom nav space
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(ChatMessage message) {
    final TextEditingController editController =
        TextEditingController(text: message.text);
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surface : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Xabarni tahrirlash",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: editController,
            maxLines: null,
            decoration: InputDecoration(
              hintText: "Xabar...",
              filled: true,
              fillColor:
                  isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Bekor qilish",
                  style: GoogleFonts.outfit(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                if (editController.text.trim().isNotEmpty) {
                  try {
                    await _chatService.updateMessage(
                        message.id, editController.text.trim());
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Xatolik: $e")),
                      );
                    }
                  }
                }
              },
              child: Text("Saqlash",
                  style: GoogleFonts.outfit(
                      color: const Color(0xFF06DF5D),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirm(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surface : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Xabarni o'chirish",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Text("Rostdan ham ushbu xabarni o'chirmoqchimisiz?",
              style: GoogleFonts.outfit()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text("Yo'q", style: GoogleFonts.outfit(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _chatService.deleteMessage(message.id);
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Xatolik: $e")),
                    );
                  }
                }
              },
              child: Text("Ha, o'chirish",
                  style: GoogleFonts.outfit(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe || message.isAdmin)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.senderName,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  if (message.isAdmin) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, size: 10, color: Colors.blue),
                  ],
                ],
              ),
            ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isAdmin && message.senderId != _myId) ...[
                IconButton(
                  onPressed: () =>
                      _chatService.toggleUserBlock(message.senderId, true),
                  icon: const Icon(Icons.block, size: 14, color: Colors.orange),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
              ],
              if (isMe || _isAdmin) ...[
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: message.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Xabar nusxalandi! 📋"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon:
                      const Icon(Icons.copy, size: 14, color: Colors.blueGrey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: "Nusxalash",
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => _showEditDialog(message),
                  icon: const Icon(Icons.edit, size: 14, color: Colors.blue),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => _showDeleteConfirm(message),
                  icon: const Icon(Icons.delete, size: 14, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: EdgeInsets.only(
                    left: isMe ? 20 : 0, // Reduced from 50
                    right: isMe ? 0 : 50,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xFF06DF5D)
                        : (isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildMessageText(message.text, isMe, isDark),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (message.views.isNotEmpty) ...[
                            Icon(
                              Icons.remove_red_eye_outlined,
                              size: 10,
                              color: isMe
                                  ? Colors.black54
                                  : (isDark ? Colors.white38 : Colors.black38),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "${message.views.length}",
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                color: isMe
                                    ? Colors.black54
                                    : (isDark
                                        ? Colors.white38
                                        : Colors.black38),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm')
                                .format(message.timestamp),
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              color: isMe
                                  ? Colors.black54
                                  : (isDark ? Colors.white38 : Colors.black38),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isMe, bool isDark) {
    if (_myId == null) return const SizedBox.shrink();

    return StreamBuilder<bool>(
      stream: _chatService.getChatStatus(),
      builder: (context, chatSnap) {
        final isPaused = chatSnap.data ?? false;

        return StreamBuilder<bool>(
          stream: _chatService.getUserStatus(_myId!),
          builder: (context, userSnap) {
            final isBlocked = userSnap.data ?? false;

            // If user is blocked, show ban message
            if (isBlocked) {
              return _buildStatusMessage(
                "Odob-axloq qoidalariga rioya qilmaganingiz uchun chetlatildingiz! 🚫",
                Colors.red,
                isDark,
              );
            }

            // If chat is paused and user is not admin, show pause message
            if (isPaused && !_isAdmin) {
              return _buildStatusMessage(
                "Hozirda chatda yozish vaqtincha to'xtatilgan! ⏸️",
                Colors.orange,
                isDark,
              );
            }

            // Otherwise, show normal input
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  top: BorderSide(
                    color: (isDark ? Colors.white : Colors.black)
                        .withOpacity(0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GlassContainer(
                      borderRadius: 24,
                      opacity: isDark ? 0.1 : 0.05,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _messageController,
                          maxLines: 5,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: "Xabar yozing...",
                            hintStyle: GoogleFonts.outfit(
                                color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: GoogleFonts.outfit(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF06DF5D),
                      radius: 24,
                      child: const Icon(Icons.send_rounded,
                          color: Colors.black, size: 22),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusMessage(String message, Color color, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageText(String text, bool isMe, bool isDark) {
    final urlRegExp = RegExp(
        r"((https?|ftp|file):\/\/|www\.)[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|]",
        caseSensitive: false);
    final matches = urlRegExp.allMatches(text);

    if (matches.isEmpty) {
      return Text(
        text,
        style: GoogleFonts.outfit(
          color: isMe ? Colors.black : (isDark ? Colors.white : Colors.black),
          fontSize: 14,
        ),
      );
    }

    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: GoogleFonts.outfit(
            color: isMe ? Colors.black : (isDark ? Colors.white : Colors.black),
            fontSize: 14,
          ),
        ));
      }

      final url = text.substring(match.start, match.end);
      spans.add(TextSpan(
        text: url,
        style: GoogleFonts.outfit(
          color: isMe ? Colors.blue.shade900 : Colors.blue,
          fontSize: 14,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final uri =
                Uri.parse(url.startsWith('http') ? url : 'https://$url');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: GoogleFonts.outfit(
          color: isMe ? Colors.black : (isDark ? Colors.white : Colors.black),
          fontSize: 14,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
