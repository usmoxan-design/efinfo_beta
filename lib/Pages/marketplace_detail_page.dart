import 'package:cached_network_image/cached_network_image.dart';
import 'package:efinfo_beta/Pages/image_preview_page.dart';
import 'package:efinfo_beta/Pages/marketplace_add_edit_page.dart';
import 'package:efinfo_beta/models/account_post.dart';
import 'package:efinfo_beta/services/auth_service.dart';
import 'package:efinfo_beta/Pages/ProfilePage.dart';
import 'package:efinfo_beta/chat/chat_service.dart'; // Corrected path
import 'package:efinfo_beta/services/marketplace_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketplaceDetailPage extends StatefulWidget {
  final AccountPost post;
  const MarketplaceDetailPage({super.key, required this.post});

  @override
  State<MarketplaceDetailPage> createState() => _MarketplaceDetailPageState();
}

class _MarketplaceDetailPageState extends State<MarketplaceDetailPage> {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  final MarketplaceService _marketplaceService = MarketplaceService();

  bool _isAdmin = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = _authService.currentUser;
    if (user != null) {
      final info = await _chatService.getUserInfo();
      if (mounted) {
        setState(() {
          _isAdmin = info['isAdmin'] == 'true';
        });
      }
    }
  }

  void _showImagePreview(String url, String tag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewPage(imageUrl: url, heroTag: tag),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = _authService.currentUser;
    final isOwner =
        currentUser != null && currentUser.uid == widget.post.userId;
    final canEdit = isOwner || _isAdmin;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: widget.post.imageUrls.length,
                    onPageChanged: (index) =>
                        setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showImagePreview(
                            widget.post.imageUrls[index],
                            'post-img-detail-${widget.post.id}-$index'),
                        child: Hero(
                          tag: 'post-img-detail-${widget.post.id}-$index',
                          child: CachedNetworkImage(
                            imageUrl: widget.post.imageUrls[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      );
                    },
                  ),
                  if (widget.post.imageUrls.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            widget.post.imageUrls.asMap().entries.map((entry) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == entry.key
                                  ? Colors.blueAccent
                                  : Colors.white.withOpacity(0.5),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: widget.post.isExchange
                              ? Colors.orange
                              : Colors.blueAccent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ]),
                      child: Text(
                          widget.post.isExchange
                              ? "OBMEN"
                              : (widget.post.price == 0
                                  ? "BEPUL"
                                  : "${NumberFormat("#,###").format(widget.post.price)} so'm"),
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (canEdit)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (val) async {
                    if (val == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MarketplaceAddEditPage(post: widget.post),
                        ),
                      );
                    } else if (val == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("O'chirish"),
                          content: const Text(
                              "Ushbu e'lonni o'chirishni tasdiqlaysizmi?"),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Yo'q")),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Ha",
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => WillPopScope(
                            onWillPop: () async => false,
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(
                                      color: Colors.redAccent),
                                  const SizedBox(height: 20),
                                  Text("Biroz kuting, e'lon o'chirilmoqda...",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.outfit(fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                        );

                        await _marketplaceService.deletePost(
                            widget.post.id, widget.post.fileIds);
                        if (mounted) {
                          Navigator.pop(context); // Close loading
                          Navigator.pop(context); // Close detail page
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'edit', child: Text("Tahrirlash")),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text("O'chirish",
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(widget.post.title,
                              style: GoogleFonts.outfit(
                                  fontSize: 24, fontWeight: FontWeight.bold))),
                      // removed duplicate price display logic, relying on the one in image or update here too?
                      // The user said "detilals page da ham tasir qilsin".
                      // I added it to the image (Positioned).
                      // If I keep the one in body, I should update logic too.
                      // Let's update the body one as well for consistency, or remove it if redundant.
                      // The body one is nice for context. I will update logic.
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                            color: (widget.post.isExchange
                                    ? Colors.orange
                                    : Colors.blueAccent)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16)),
                        child: Text(
                            widget.post.isExchange
                                ? "OBMEN"
                                : (widget.post.price == 0
                                    ? "BEPUL"
                                    : "${NumberFormat("#,###").format(widget.post.price)} so'm"),
                            style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: widget.post.isExchange
                                    ? Colors.orange
                                    : Colors.blueAccent)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfilePage(userId: widget.post.userId))),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline_rounded,
                                size: 16, color: Colors.blueAccent),
                            const SizedBox(width: 6),
                            Text(widget.post.userName,
                                style: GoogleFonts.outfit(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.w600)),
                            if (widget.post.isAuthorAdmin)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.verified,
                                    size: 14, color: Colors.blue),
                              ),
                            if (isOwner)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text("Siz",
                                    style: GoogleFonts.outfit(
                                        fontSize: 10, color: Colors.grey)),
                              ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                          DateFormat('dd.MM.yyyy HH:mm')
                              .format(widget.post.createdAt),
                          style: GoogleFonts.outfit(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag("Google Account", widget.post.googleAccount),
                      _buildTag("Konami ID", widget.post.konamiId),
                      _buildTag("GameCenter", widget.post.gameCenter),
                      _buildTag("Obmen", widget.post.isExchange),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text("Tavsif",
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(widget.post.description,
                      style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.6)),
                  const SizedBox(height: 40),
                  Text("Bog'lanish",
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildContactCard(
                      icon: Icons.telegram_rounded,
                      title: widget.post.telegramUser,
                      subtitle: "Telegram orqali yozish",
                      color: const Color(0xFF0088cc),
                      onTap: () async {
                        final url = Uri.parse(
                            "https://t.me/${widget.post.telegramUser.replaceAll('@', '')}");
                        if (await canLaunchUrl(url)) await launchUrl(url);
                      }),
                  const SizedBox(height: 12),
                  if (widget.post.phoneNumber.isNotEmpty &&
                      widget.post.phoneNumber != '+998')
                    _buildContactCard(
                        icon: Icons.phone_forwarded_rounded,
                        title: widget.post.phoneNumber,
                        subtitle: "Qo'ng'iroq qilish",
                        color: Colors.green,
                        onTap: () async {
                          final url =
                              Uri.parse("tel:${widget.post.phoneNumber}");
                          if (await canLaunchUrl(url)) await launchUrl(url);
                        }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161618) : Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5))
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () async {
            final url = Uri.parse(
                "https://t.me/${widget.post.telegramUser.replaceAll('@', '')}");
            if (await canLaunchUrl(url)) await launchUrl(url);
          },
          icon: const Icon(Icons.send_rounded),
          label: const Text("Telegramda bog'lanish"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0088cc),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, bool isActive) {
    final color = isActive ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? Icons.check_circle : Icons.cancel,
              size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildContactCard(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color:
                    isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: GoogleFonts.outfit(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          GoogleFonts.outfit(fontSize: 12, color: Colors.grey))
                ])),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
