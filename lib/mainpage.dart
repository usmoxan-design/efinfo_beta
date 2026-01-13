import 'package:flutter/services.dart';
import 'package:efinfo_beta/Pages/HomePage.dart';
import 'package:efinfo_beta/Pages/SettingsPage.dart';
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
    SettingsPage(),
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
        extendBody: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
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
            if (_currentIndex != 2 && _currentIndex != 1)
              _buildTelegramBanner(),
            _buildBottomNavBar(themeProvider),
          ],
        ),
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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF229ED9).withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF229ED9).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.telegram, color: Color(0xFF229ED9), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Telegram kanalimizga obuna bo'ling",
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _launchTelegram,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: const Color(0xFF229ED9),
            ),
            child: Text(
              "O'tish",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
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
        _buildNavDestination(IonIcons.settings, 'Sozlamalar', 3, isDark),
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

class _NotificationBottomSheet extends StatefulWidget {
  final bool isDark;
  const _NotificationBottomSheet({required this.isDark});

  @override
  State<_NotificationBottomSheet> createState() =>
      _NotificationBottomSheetState();
}

class _NotificationBottomSheetState extends State<_NotificationBottomSheet> {
  final Set<String> _loadingIds = {};
  final OnlineTournamentService _tournamentService = OnlineTournamentService();

  Future<void> _handleAction(
      String requestId, String tournamentName, bool accept) async {
    // Show global loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF06DF5D)),
              const SizedBox(height: 20),
              Text("Biroz kuting, so'rov bajarilmoqda...",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 16)),
            ],
          ),
        ),
      ),
    );

    try {
      await _tournamentService.handleRequest(requestId, accept);
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accept
                ? "\"$tournamentName\" turniriga muvaffaqiyatli qo'shildingiz!"
                : "Turnir taklifi rad etildi."),
            backgroundColor: accept ? const Color(0xFF06DF5D) : Colors.orange,
          ),
        );
        Navigator.pop(context); // Close BottomSheet
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Xato yuz berdi: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Bildirishnomalar",
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _tournamentService.getMyRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final requests = snapshot.data ?? [];
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
                    final String reqId = req['id'];
                    final String tourName = req['tournamentName'];
                    final bool isLoading = _loadingIds.contains(reqId);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${req['fromName']} sizni \"$tourName\" turniriga taklif qildi.",
                            style: GoogleFonts.outfit(
                              color: widget.isDark
                                  ? Colors.white70
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isLoading)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.grey),
                                )
                              else ...[
                                TextButton(
                                  onPressed: () =>
                                      _handleAction(reqId, tourName, false),
                                  child: Text("Rad etish",
                                      style: GoogleFonts.outfit(
                                          color: Colors.redAccent)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () =>
                                      _handleAction(reqId, tourName, true),
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
