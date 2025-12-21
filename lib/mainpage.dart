import 'package:efinfo_beta/Pages/HomePage.dart';
import 'package:efinfo_beta/Pages/MorePage.dart';
import 'package:efinfo_beta/tournament/TournamentMaker.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/mainLogo.png',
              height: 32,
            ),
            const SizedBox(width: 15),
            Text(
              "Version 1.0.7",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textDim,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTelegramBanner(),
          _buildBottomNavBar(),
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
                  "Eng so\'nggi yangiliklarni o'tkazib yubormang",
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
              "Qo\'shilish",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: NavigationBar(
        height: 65,
        elevation: 0,
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.accentPink.withOpacity(0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          _buildNavDestination(IonIcons.apps, "Hub", 0),
          _buildNavDestination(IonIcons.trophy, 'Turnirchi', 1),
          _buildNavDestination(EvaIcons.grid, "Ko'proq", 2),
        ],
      ),
    );
  }

  NavigationDestination _buildNavDestination(
      IconData icon, String label, int index) {
    return NavigationDestination(
      icon: Icon(icon, color: AppColors.textDim),
      selectedIcon: Icon(icon, color: AppColors.accentPink),
      label: label,
    );
  }
}
