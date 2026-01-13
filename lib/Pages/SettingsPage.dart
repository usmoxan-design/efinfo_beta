import 'package:efinfo_beta/Pages/auth_page.dart';
import 'package:efinfo_beta/Pages/marketplace_my_posts_page.dart';
import 'package:efinfo_beta/services/auth_service.dart';
import 'package:efinfo_beta/chat/chat_service.dart';
import 'package:efinfo_beta/services/marketplace_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  final MarketplaceService _marketplaceService = MarketplaceService();

  String? _userName;
  String? _userEmail;
  int _postCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final count = await _marketplaceService.getUserPostCount(user.uid);
      final info = await _chatService.getUserInfoByOtherId(user.uid);

      if (mounted) {
        setState(() {
          _userName = info['name'] ?? 'Nomalum';
          _userEmail = info['email'] ?? user.email;
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "Sozlamalar",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (user == null)
                  _buildLoginCard(isDark)
                else
                  _buildProfileHeader(isDark),
                const SizedBox(height: 30),
                _buildSectionTitle("Hisob"),
                const SizedBox(height: 15),
                if (user != null) ...[
                  _buildSettingTile(
                    context,
                    icon: IonIcons.person,
                    title: "Profilni tahrirlash",
                    subtitle: "Ismni o'zgartirish",
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: _editName,
                  ),
                  const SizedBox(height: 12),
                  _buildSettingTile(
                    context,
                    icon: Icons.list_alt,
                    title: "Mening e'lonlarim",
                    subtitle: "Siz qo'ygan e'lonlar",
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MyMarketplacePostsPage())),
                  ),
                  const SizedBox(height: 12),
                ],
                _buildSectionTitle("Ko'rinish"),
                const SizedBox(height: 15),
                _buildSettingTile(
                  context,
                  icon: isDark ? IonIcons.moon : IonIcons.sunny,
                  title: "Qorong'u rejim",
                  subtitle: "Ilovani tungi rejimga o'tkazish",
                  trailing: Switch.adaptive(
                    value: isDark,
                    activeColor: const Color(0xFF06DF5D),
                    onChanged: (value) => themeProvider.toggleTheme(),
                  ),
                ),
                const SizedBox(height: 30),
                _buildSectionTitle("Ilova haqida"),
                const SizedBox(height: 15),
                _buildSettingTile(
                  context,
                  icon: IonIcons.information_circle,
                  title: "Versiya",
                  subtitle: "1.1.0",
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                _buildSettingTile(
                  context,
                  icon: IonIcons.paper_plane,
                  title: "Telegram kanalimiz",
                  subtitle: "@eFootball_Info_Hub",
                  trailing: const Icon(Icons.open_in_new,
                      size: 20, color: Colors.grey),
                  onTap: () =>
                      launchUrl(Uri.parse("https://t.me/eFootball_Info_Hub")),
                ),
                if (user != null) ...[
                  const SizedBox(height: 40),
                  _buildSettingTile(
                    context,
                    icon: IonIcons.log_out,
                    title: "Chiqish",
                    subtitle: "Hisobdan chiqish",
                    trailing: const Icon(Icons.chevron_right,
                        color: Colors.redAccent),
                    iconColor: Colors.redAccent,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: Text("Hisobdan chiqish",
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold)),
                          content: Text(
                              "Haqiqatan ham hisobdan chiqmoqchimisiz?",
                              style:
                                  GoogleFonts.outfit(color: Colors.grey[700])),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Yo'q",
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context); // Close dialog

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => WillPopScope(
                                    onWillPop: () async => false,
                                    child: AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const CircularProgressIndicator(
                                              color: Colors.redAccent),
                                          const SizedBox(height: 20),
                                          Text(
                                              "Biroz kuting, hisobdan chiqilmoqda...",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.outfit(
                                                  fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );

                                await _authService.signOut();
                                if (mounted) {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/', (route) => false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              child: Text("Ha",
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 100),
              ],
            ),
    );
  }

  Widget _buildLoginCard(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.account_circle_outlined,
              size: 60, color: Colors.blueAccent.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            "Hisobingizga kiring",
            style:
                GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "E'lonlarni boshqarish uchun tizimga kiring",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AuthPage()))
                  .then((_) => _loadProfile()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("KIRISH"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                child: Text(
                  _userName != null && _userName!.isNotEmpty
                      ? _userName![0].toUpperCase()
                      : "?",
                  style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName ?? "Noma'lum",
                      style: GoogleFonts.outfit(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _userEmail ?? "",
                      style:
                          GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              _buildStatItem("E'lonlar", _postCount.toString(), Icons.list_alt),
              const VerticalDivider(),
              StreamBuilder<int>(
                  stream:
                      _authService.getUserCoins(_authService.currentUser!.uid),
                  builder: (context, snapshot) {
                    return _buildStatItem(
                        "Coinlar",
                        snapshot.data?.toString() ?? "0",
                        Icons.payments_outlined,
                        color: Colors.amber);
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color ?? Colors.blueAccent, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label,
              style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF06DF5D),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFF06DF5D)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: iconColor ?? const Color(0xFF06DF5D), size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
