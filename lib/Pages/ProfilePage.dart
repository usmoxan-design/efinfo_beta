import 'package:efinfo_beta/Pages/auth_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:efinfo_beta/Pages/marketplace_list_page.dart';
import 'package:efinfo_beta/Pages/marketplace_my_posts_page.dart';
import 'package:efinfo_beta/models/account_post.dart';
import 'package:efinfo_beta/services/auth_service.dart';
import 'package:efinfo_beta/chat/chat_service.dart';
import 'package:efinfo_beta/services/marketplace_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final String? userId; // Optional: if null, show current user profile
  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  final MarketplaceService _marketplaceService = MarketplaceService();

  String? _userName;
  String? _userEmail;
  int _postCount = 0;
  bool _isLoading = true;
  bool _isMe = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final targetUserId = widget.userId ?? _authService.currentUser?.uid;

    if (targetUserId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    _isMe = targetUserId == _authService.currentUser?.uid;

    try {
      // Load post count
      final count = await _marketplaceService.getUserPostCount(targetUserId);

      // Load user info from Firestore (chat_users collection)
      final info = await _chatService.getUserInfoByOtherId(targetUserId);

      if (mounted) {
        setState(() {
          _userName = info['name'] ?? 'Nomalum';
          _userEmail = info['email']; // May be null if not current user
          _postCount = count;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _editName() async {
    final TextEditingController nameController =
        TextEditingController(text: _userName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ismni tahrirlash"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Yangi ism"),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Bekor qilish")),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text("Saqlash"),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != _userName) {
      await _chatService.saveUserName(newName);
      setState(() => _userName = newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If no target user and not logged in
    if (_authService.currentUser == null && widget.userId == null) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text("Profil",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle_outlined,
                    size: 80, color: Colors.blueAccent.withOpacity(0.5)),
                const SizedBox(height: 24),
                Text(
                  "Hisobingizga kiring",
                  style: GoogleFonts.outfit(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  "Profilni ko'rish va e'lonlarni boshqarish uchun tizimga kiring.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AuthPage()))
                        .then((_) => _loadProfile()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text("KIRISH",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_userName == null && widget.userId != null) {
      return const Scaffold(
          body: Center(child: Text("Foydalanuvchi topilmadi")));
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_isMe ? "Mening Profilim" : "Foydalanuvchi Profili",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header: Avatar and Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    child: Text(
                      _userName != null && _userName!.isNotEmpty
                          ? _userName![0].toUpperCase()
                          : "?",
                      style: GoogleFonts.outfit(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userName ?? "Noma'lum",
                    style: GoogleFonts.outfit(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (_isMe && _userEmail != null)
                    Text(
                      _userEmail!,
                      style:
                          GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildStatCard("E'lonlar", _postCount.toString(),
                      Icons.inventory_2_outlined),
                  if (_isMe && _authService.currentUser != null) ...[
                    const SizedBox(width: 12),
                    StreamBuilder<int>(
                        stream: _authService
                            .getUserCoins(_authService.currentUser!.uid),
                        builder: (context, snapshot) {
                          return _buildStatCard(
                            "Coinlar",
                            snapshot.data?.toString() ?? "0",
                            Icons.monetization_on_rounded,
                            iconColor: Colors.amber,
                            onAddTap: () async {
                              final url = Uri.parse("https://t.me/eFinfo_HUB");
                              if (await canLaunchUrl(url)) await launchUrl(url);
                            },
                          );
                        }),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            if (_isMe) ...[
              _buildActionTile(
                icon: Icons.edit_rounded,
                title: "Ismni tahrirlash",
                onTap: _editName,
                isDark: isDark,
              ),
              _buildActionTile(
                icon: Icons.list_alt_rounded,
                title: "Mening E'lonlarim",
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyMarketplacePostsPage())),
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              _buildActionTile(
                icon: Icons.logout_rounded,
                title: "Chiqish",
                color: Colors.redAccent,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Chiqish"),
                      content:
                          const Text("Haqiqatan ham hisobdan chiqmoqchimisiz?"),
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
                    await _authService.signOut();
                    if (mounted) Navigator.pop(context);
                  }
                },
                isDark: isDark,
              ),
            ] else ...[
              // If not current user, maybe show their posts directly?
              _buildSectionTitle("Foydalanuvchi e'lonlari"),
              _buildUserPostsList(widget.userId!),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon,
      {Color? iconColor, VoidCallback? onAddTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor ?? Colors.blueAccent),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                if (onAddTap != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onAddTap,
                    child: const Icon(Icons.add_circle_outline_rounded,
                        color: Colors.blueAccent, size: 18),
                  ),
                ],
              ],
            ),
            Text(label,
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    Color? color,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? Colors.blueAccent).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? Colors.blueAccent, size: 20),
      ),
      title: Text(title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: color)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style:
                GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildUserPostsList(String userId) {
    return StreamBuilder<List<AccountPost>>(
      stream: _marketplaceService.getPosts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final posts = snapshot.data!.where((p) => p.userId == userId).toList();
        if (posts.isEmpty) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Hozircha e'lonlar yo'q"),
          ));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemBuilder: (context, index) {
            return MarketplaceListPage.buildStaticPostCard(
                context, posts[index]);
          },
        );
      },
    );
  }
}
