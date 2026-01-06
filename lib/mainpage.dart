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

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
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
              "v1.0.10",
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? AppColors.textDim : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatPage()),
              );
            },
            icon: Icon(
              IonIcons.chatbox_ellipses,
              color: isDark ? Colors.white : Colors.black,
            ),
            tooltip: "Chat",
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
          _buildTelegramBanner(),
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
        _buildNavDestination(IonIcons.trophy, 'Turnirchi', 1, isDark),
        _buildNavDestination(EvaIcons.grid, "Ko'proq", 2, isDark),
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
}
