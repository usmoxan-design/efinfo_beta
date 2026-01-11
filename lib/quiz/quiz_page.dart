import 'package:efinfo_beta/quiz/quiz_data.dart';
import 'package:efinfo_beta/quiz/quiz_game_page.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _highScore = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await QuizData.ensureLoaded();
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _highScore = prefs.getInt('quiz_highscore') ?? 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Player Quiz",
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? RadialGradient(
                        center: const Alignment(0, -0.2),
                        radius: 1.5,
                        colors: [
                          const Color(0xFF1A1A2E), // Deep Blue
                          AppColors.background,
                        ],
                      )
                    : null,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _buildUserCard(isDark),
                      const SizedBox(height: 50),
                      _buildGameModeCard(
                        context,
                        title: "O'yinni boshlash",
                        subtitle: "O'yinchilarni toping",
                        icon: Icons.play_arrow_rounded,
                        color: AppColors.accent,
                        onTap: () => _startGame(context, league: "All"),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "O'yin qoidasi: Rasmdagi o'yinchini ismini 4 ta variant ichidan topishingiz kerak. Har bir to'g'ri javob uchun ball beriladi.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLeagueButton(BuildContext context,
      {required String title, required String fullLeague}) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return GestureDetector(
      onTap: () => _startGame(context, league: fullLeague),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(bool isDark) {
    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.emoji_events,
                color: AppColors.accent, size: 30),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sizning Rekordingiz",
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
              ),
              Text(
                "$_highScore",
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: isDark ? Colors.white30 : Colors.black38),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context, {String? league}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizGamePage(league: league)),
    ).then((_) => _initData());
  }
}
