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
  Map<String, int> _highScores = {
    'Oson': 0,
    'Standart': 0,
    'Qiyin': 0,
    'Ekstremal': 0,
  };
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
        _highScores = {
          'Oson': prefs.getInt('quiz_highscore_Oson') ?? 0,
          'Standart': prefs.getInt('quiz_highscore_Standart') ?? 0,
          'Qiyin': prefs.getInt('quiz_highscore_Qiyin') ?? 0,
          'Ekstremal': prefs.getInt('quiz_highscore_Ekstremal') ?? 0,
        };
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        _buildHighScoresGrid(isDark),
                        const SizedBox(height: 30),
                        Text(
                          "O'yin rejimini tanlang:",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildGameModeCard(
                          context,
                          title: "Oson",
                          subtitle: "Harf ko'p, imkoniyatlar yo'q",
                          icon: Icons.sentiment_satisfied_rounded,
                          color: Colors.green,
                          onTap: () => _startGame(context, mode: "Oson"),
                        ),
                        const SizedBox(height: 12),
                        _buildGameModeCard(
                          context,
                          title: "Standart",
                          subtitle: "O'rtacha qiyinchilik",
                          icon: Icons.sentiment_neutral_rounded,
                          color: AppColors.accent,
                          onTap: () => _startGame(context, mode: "Standart"),
                        ),
                        const SizedBox(height: 12),
                        _buildGameModeCard(
                          context,
                          title: "Qiyin",
                          subtitle: "Harf kam, haqiqiy sinov",
                          icon: Icons.sentiment_very_dissatisfied_rounded,
                          color: Colors.redAccent,
                          onTap: () => _startGame(context, mode: "Qiyin"),
                        ),
                        const SizedBox(height: 12),
                        _buildGameModeCard(
                          context,
                          title: "Ekstremal",
                          subtitle: "Hech qanday shama yo'q!",
                          icon: Icons.whatshot_rounded,
                          color: Colors.purpleAccent,
                          onTap: () => _startGame(context, mode: "Ekstremal"),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "O'yin qoidasi: Rasmdagi o'yinchini ismini bo'sh katakchadagi harflarini topishingiz kerak. Har bir to'g'ri javob uchun ball beriladi.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHighScoresGrid(bool isDark) {
    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: AppColors.accent, size: 24),
              const SizedBox(width: 8),
              Text(
                "Sizning Rekordlaringiz",
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: _highScores.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      entry.key,
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      entry.value.toString(),
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 17,
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
                size: 14, color: isDark ? Colors.white30 : Colors.black38),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context,
      {String? league, String mode = 'Standart'}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => QuizGamePage(league: league, mode: mode)),
    ).then((_) => _initData());
  }
}
