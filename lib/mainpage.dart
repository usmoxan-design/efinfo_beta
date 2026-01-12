import 'package:efinfo_beta/Pages/HomePage.dart';
import 'package:efinfo_beta/Pages/MorePage.dart';
import 'package:efinfo_beta/Pages/marketplace_list_page.dart';
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
import 'package:efinfo_beta/services/auth_service.dart';
import 'package:efinfo_beta/services/online_tournament_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  final OnlineTournamentService _tournamentService = OnlineTournamentService();

  final List<Widget> _pages = const [
    HomePage(),
    TournamentListPage(),
    MarketplaceListPage(),
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
    final user = _authService.currentUser;

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
          ],
        ),
        actions: [
          if (user != null) ...[
            StreamBuilder<int>(
                stream: _authService.getUserCoins(user.uid),
                builder: (context, snapshot) {
                  return Center(
                    child: GestureDetector(
                      onTap: () =>
                          launchUrl(Uri.parse("https://t.me/eFinfo_HUB")),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on_rounded,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "${snapshot.data ?? 0}",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.add_circle_outline_rounded,
                                color: Colors.blueAccent, size: 14),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            StreamBuilder<int>(
                stream: _tournamentService.getRequestsCount(),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Stack(
                    children: [
                      IconButton(
                        onPressed: () => _showNotifications(context, isDark),
                        icon: Icon(IonIcons.notifications,
                            color: isDark ? Colors.white : Colors.black),
                      ),
                      if (count > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            constraints: const BoxConstraints(
                                minWidth: 16, minHeight: 16),
                            child: Text(
                              "$count",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
          ],
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
          if (_currentIndex != 2 && _currentIndex != 1) _buildTelegramBanner(),
          _buildBottomNavBar(themeProvider),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _NotificationBottomSheet(isDark: isDark),
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
        _buildNavDestination(IonIcons.trophy, 'Turnir', 1, isDark),
        _buildNavDestination(IonIcons.cart, 'Savdo', 2, isDark),
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
}

class _NotificationBottomSheet extends StatelessWidget {
  final bool isDark;
  const _NotificationBottomSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final tournamentService = OnlineTournamentService();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Bildirishnomalar",
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: tournamentService.getMyRequests(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final requests = snapshot.data!;
                if (requests.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        "Hozircha xabarlar yo'q",
                        style: GoogleFonts.outfit(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${req['fromName']} sizni \"${req['tournamentName']}\" turniriga taklif qildi.",
                            style: GoogleFonts.outfit(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => tournamentService
                                    .handleRequest(req['id'], false),
                                child: Text("Rad etish",
                                    style: GoogleFonts.outfit(
                                        color: Colors.redAccent)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => tournamentService
                                    .handleRequest(req['id'], true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF06DF5D),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text("Qabul qilish",
                                    style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
