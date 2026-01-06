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
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  String? _myId;
  String? _myName;
  bool _isLoading = true;
  bool _isAdmin = false;
  final bool _isChatPaused = false;
  final Set<String> _readMessages = {};
  ChatMessage? _replyMessage;
  String? _highlightedMessageId;
  bool _showScrollDownButton = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _itemPositionsListener.itemPositions.addListener(_scrollListener);
  }

  void _scrollListener() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      final minIndex = positions
          .where((ItemPosition position) => position.itemTrailingEdge > 0)
          .reduce((ItemPosition min, ItemPosition position) =>
              position.index < min.index ? position : min)
          .index;

      final show = minIndex > 3;
      if (show != _showScrollDownButton) {
        setState(() => _showScrollDownButton = show);
      }
    }
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_scrollListener);
    super.dispose();
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
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF06DF5D).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF06DF5D),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Chatda ishtirok eting!",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Xabarlaringiz boshqalarga qaysi ism bilan ko'rinishini istaysiz? Ismingizni kiriting.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Ismingiz yoki Taxallusingiz...",
                  hintStyle:
                      GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor:
                      isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: GoogleFonts.outfit(),
              ),
            ],
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
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  await _chatService.saveUserName(nameController.text.trim());
                  setState(() {
                    _myName = nameController.text.trim();
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06DF5D),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                "Saqlash",
                style: GoogleFonts.outfit(
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
    final replyTo = _replyMessage;
    _messageController.clear();
    setState(() => _replyMessage = null);

    try {
      await _chatService.sendMessage(text, _myId!, _myName!, _isAdmin,
          replyToId: replyTo?.id,
          replyToName: replyTo?.senderName,
          replyToText: replyTo?.text,
          replyToSenderId: replyTo?.senderId);
      if (_itemScrollController.isAttached) {
        _itemScrollController.jumpTo(index: 0);
      }
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
          // backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: _showAdminLoginDialog,
                  child: Text(
                    "Ommaviy Chat",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
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
            actions: [
              TextButton.icon(
                onPressed: _showNameDialog,
                icon: const Icon(Icons.edit_note,
                    size: 20, color: Color(0xFF06DF5D)),
                label: Text(
                  "Ismni o'zgartirish",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF06DF5D),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Header
              if (_isAdmin)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                              color: isPaused
                                  ? const Color(0xFF06DF5D)
                                  : Colors.red,
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
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child:
                                        const Text("Ha, barchasini o'chirish")),
                              ],
                            ),
                          );
                          if (confirm == true)
                            await _chatService.clearAllMessages();
                        },
                        icon: const Icon(Icons.delete_sweep,
                            color: Colors.orange),
                        tooltip: "Chatni tozalash",
                      ),
                    ],
                  ),
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

                    return ScrollablePositionedList.builder(
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener,
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

                        return _buildMessageBubble(
                            message, isMe, isDark, messages);
                      },
                    );
                  },
                ),
              ),

              // Input Area
              _buildInputArea(true, isDark),
              const SizedBox(height: 80), // Bottom nav space
            ],
          ),
          floatingActionButton: _showScrollDownButton
              ? FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    _itemScrollController.scrollTo(
                      index: 0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  backgroundColor: const Color(0xFF06DF5D),
                  elevation: 4,
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.black),
                )
              : null,
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
        bool isSaving = false;
        return StatefulBuilder(builder: (context, setDialogState) {
          final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
          return AlertDialog(
            backgroundColor: isDark ? AppColors.surface : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text("Xabarni tahrirlash",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSaving)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF06DF5D)),
                  )
                else
                  TextField(
                    controller: editController,
                    maxLines: 5,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: "Xabar...",
                      filled: true,
                      fillColor: isDark
                          ? Colors.white10
                          : Colors.black.withOpacity(0.05),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: GoogleFonts.outfit(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: Text("Bekor qilish",
                    style: GoogleFonts.outfit(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (editController.text.trim().isNotEmpty) {
                          setDialogState(() => isSaving = true);
                          try {
                            await _chatService.updateMessage(
                                message.id, editController.text.trim());
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Xatolik: $e")),
                              );
                              Navigator.pop(context);
                            }
                          }
                        } else {
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06DF5D),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text("Saqlash",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );
  }

  void _showDeleteConfirm(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(builder: (context, setDialogState) {
          final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
          return AlertDialog(
            backgroundColor: isDark ? AppColors.surface : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text("Xabarni o'chirish",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: isDeleting
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.red),
                      SizedBox(width: 16),
                      Text("O'chirilmoqda...")
                    ],
                  )
                : Text("Rostdan ham ushbu xabarni o'chirmoqchimisiz?",
                    style: GoogleFonts.outfit()),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(context),
                child:
                    Text("Yo'q", style: GoogleFonts.outfit(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: isDeleting
                    ? null
                    : () async {
                        setDialogState(() => isDeleting = true);
                        try {
                          await _chatService.deleteMessage(message.id);
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Xatolik: $e")),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text("Ha, o'chirish",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );
  }

  void _showMessageActions(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
        final isMe = message.senderId == _myId;

        return AlertDialog(
          backgroundColor: isDark ? AppColors.surface : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("Amallar",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionItem(
                icon: Icons.reply,
                title: "Javob berish",
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _replyMessage = message);
                },
              ),
              _buildActionItem(
                icon: Icons.copy,
                title: "Nusxalash",
                color: Colors.blueGrey,
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: message.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Xabar nusxalandi! 📋"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              if (isMe || _isAdmin) ...[
                _buildActionItem(
                  icon: Icons.edit,
                  title: "Tahrirlash",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _showEditDialog(message);
                  },
                ),
                _buildActionItem(
                  icon: Icons.delete,
                  title: "O'chirish",
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirm(message);
                  },
                ),
              ],
              if (_isAdmin && message.senderId != _myId) ...[
                StreamBuilder<bool>(
                  stream: _chatService.getUserStatus(message.senderId),
                  builder: (context, snapshot) {
                    final isBlocked = snapshot.data ?? false;
                    return _buildActionItem(
                      icon: isBlocked ? Icons.check_circle : Icons.block,
                      title: isBlocked ? "Blokdan chiqarish" : "Bloklash",
                      color: isBlocked ? Colors.green : Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        _chatService.toggleUserBlock(
                            message.senderId, !isBlocked);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isBlocked
                                ? "Foydalanuvchi blokdan chiqarildi! ✅"
                                : "Foydalanuvchi bloklandi! 🚫"),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: GoogleFonts.outfit()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe, bool isDark,
      List<ChatMessage> allMessages) {
    final isHighlighted = _highlightedMessageId == message.id;
    final userColor = _getUserColor(message.senderId);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? (isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05))
            : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: userColor.withOpacity(0.2),
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : "?",
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: userColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => _showMessageActions(message),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFF6B4EE6)
                          : (isDark
                              ? const Color(0xFF2B333E)
                              : const Color(0xFFE9E9EB)),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isMe || message.isAdmin) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message.senderName,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isMe ? Colors.white70 : userColor,
                                ),
                              ),
                              if (message.isAdmin) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified,
                                    size: 12, color: Colors.blue),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        if (message.replyToName != null)
                          _buildReplyInBubble(message, isDark, allMessages),
                        _buildMessageText(message.text, isMe, isDark),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm')
                                  .format(message.timestamp),
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                color: isMe
                                    ? Colors.white60
                                    : (isDark
                                        ? Colors.white38
                                        : Colors.black38),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Views count
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 10,
                                  color: isMe
                                      ? Colors.white60
                                      : (isDark
                                          ? Colors.white38
                                          : Colors.black38),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  "${message.views.length}",
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    color: isMe
                                        ? Colors.white60
                                        : (isDark
                                            ? Colors.white38
                                            : Colors.black38),
                                  ),
                                ),
                              ],
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              Icon(
                                message.views.isNotEmpty
                                    ? Icons.done_all
                                    : Icons.done,
                                size: 12,
                                color: Colors.white70,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _showMessageActions(message),
                icon: Icon(Icons.more_vert,
                    size: 18, color: isDark ? Colors.white54 : Colors.black54),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: "Ko'proq",
              ),
              const SizedBox(height: 4),
              IconButton(
                onPressed: () => setState(() => _replyMessage = message),
                icon: Icon(Icons.reply,
                    size: 18, color: isDark ? Colors.white54 : Colors.black54),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: "Javob berish",
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
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_replyMessage != null) _buildReplyPreview(isDark),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                ),
              ],
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

  Widget _buildReplyPreview(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
        border: Border(
            left: const BorderSide(color: Color(0xFF06DF5D), width: 4),
            top: BorderSide(
                color:
                    (isDark ? Colors.white : Colors.black).withOpacity(0.05))),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply, color: Color(0xFF06DF5D), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _replyMessage?.senderName ?? "",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF06DF5D),
                  ),
                ),
                Text(
                  _replyMessage?.text ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _replyMessage = null),
            icon: const Icon(Icons.close, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyInBubble(
      ChatMessage message, bool isDark, List<ChatMessage> allMessages) {
    return GestureDetector(
      onTap: () => _scrollToMessage(message.replyToId, allMessages),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: message.replyToSenderId != null
                  ? _getUserColor(message.replyToSenderId!)
                  : Colors.grey,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.replyToName ?? "",
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: message.senderId == _myId
                    ? Colors.white70
                    : (message.replyToSenderId != null
                        ? _getUserColor(message.replyToSenderId!)
                        : (isDark ? Colors.white70 : Colors.black54)),
              ),
            ),
            Text(
              message.replyToText ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: message.senderId == _myId
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToMessage(String? messageId, List<ChatMessage> allMessages) {
    if (messageId == null) return;
    final index = allMessages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      // Highlight effect
      setState(() => _highlightedMessageId = messageId);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _highlightedMessageId = null);
        }
      });
    }
  }

  Color _getUserColor(String userId) {
    final List<Color> colors = [
      Colors.blue,
      Colors.redAccent,
      Colors.orange,
      Colors.purpleAccent,
      Colors.teal,
      Colors.pinkAccent,
      Colors.indigoAccent,
      Colors.brown,
      Colors.deepOrange,
      Colors.cyan,
    ];
    // Simple hash to pick a stable color for the same user
    final int hash = userId.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
