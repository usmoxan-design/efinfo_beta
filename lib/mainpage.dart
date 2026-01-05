import 'package:efinfo_beta/Pages/HomePage.dart';
import 'package:efinfo_beta/Pages/MorePage.dart';
import 'package:efinfo_beta/Pages/SettingsPage.dart';
import 'package:efinfo_beta/tournament/TournamentMaker.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:efinfo_beta/chat/chat_page.dart';
import 'package:efinfo_beta/chat/chat_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ChatPage(),
    TournamentListPage(),
    MorePage(),
  ];

  Future<void> _launchTelegram() async {
    final Uri url = Uri.parse('https://t.me/eFootball_Info_Hub');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: themeProvider.isGlassMode
            ? const GlassContainer(
                borderRadius: 0,
                child: SizedBox.expand(),
              )
            : Container(color: isDark ? AppColors.surface : Colors.white),
        title: Row(
          children: [
            Image.asset(
              'assets/images/mainLogo.png',
              height: 32,
            ),
            const SizedBox(width: 15),
            Text(
              "Version 1.0.10",
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? AppColors.textDim : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (_currentIndex == 1)
            IconButton(
              onPressed: () => _showNameDialog(context),
              icon: const Icon(Icons.person_outline),
              tooltip: "Ismni o'zgartirish",
            ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: Icon(
              IonIcons.settings,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentIndex != 1) _buildTelegramBanner(),
          _buildBottomNavBar(themeProvider),
        ],
      ),
    );
  }

  Widget _buildTelegramBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF229ED9), Color(0xFF1B8ABA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF229ED9).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.telegram, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@eFootball_Info_Hub",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Eng so'nggi yangiliklarni o'tkazib yubormang",
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _launchTelegram,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF229ED9),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              "Qo'shilish",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: ClipRRect(
        child: themeProvider.isGlassMode
            ? GlassContainer(
                borderRadius: 0,
                blur: 20,
                opacity: isDark ? 0.05 : 0.1,
                child: _navigationBar(themeProvider),
              )
            : Container(
                color: isDark ? AppColors.surface : Colors.white,
                child: _navigationBar(themeProvider),
              ),
      ),
    );
  }

  Widget _navigationBar(ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;
    return NavigationBar(
      height: 65,
      elevation: 0,
      backgroundColor: Colors.transparent,
      indicatorColor: const Color(0xFF06DF5D).withOpacity(0.2),
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() => _currentIndex = index);
      },
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        _buildNavDestination(IonIcons.apps, "Hub", 0, isDark),
        _buildNavDestination(IonIcons.chatbox_ellipses, "Chat", 1, isDark),
        _buildNavDestination(IonIcons.trophy, 'Turnirchi', 2, isDark),
        _buildNavDestination(EvaIcons.grid, "Ko'proq", 3, isDark),
      ],
    );
  }

  NavigationDestination _buildNavDestination(
      IconData icon, String label, int index, bool isDark) {
    return NavigationDestination(
      icon: Icon(icon, color: isDark ? Colors.white54 : Colors.black54),
      selectedIcon: Icon(icon, color: const Color(0xFF06DF5D)),
      label: label,
    );
  }

  void _showNameDialog(BuildContext context) async {
    final chatService = ChatService();
    final info = await chatService.getUserInfo();
    final String currentName = info['name'] ?? '';
    final TextEditingController nameController =
        TextEditingController(text: currentName);

    if (!context.mounted) return;

    showDialog(
      context: context,
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
                  await chatService.saveUserName(nameController.text.trim());
                  if (context.mounted) Navigator.pop(context);
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
}
