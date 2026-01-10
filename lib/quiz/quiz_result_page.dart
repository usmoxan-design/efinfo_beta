import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizResultPage extends StatefulWidget {
  final int score;
  final int totalQuestions;

  const QuizResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  bool _isNewRecord = false;

  @override
  void initState() {
    super.initState();
    _updateStats();
  }

  Future<void> _updateStats() async {
    final prefs = await SharedPreferences.getInstance();

    // Update High Score
    int currentHigh = prefs.getInt('quiz_highscore') ?? 0;
    if (widget.score > currentHigh) {
      prefs.setInt('quiz_highscore', widget.score);
      if (mounted) {
        setState(() {
          _isNewRecord = true;
        });
      }
    }
  }

  void _shareResult() {
    Share.share(
      "eFootball Logo Quiz da ${widget.score}/${widget.totalQuestions} natija qayd etdim! \n Siz ham kuchingizni sinab ko'ring!",
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final percentage = widget.score / widget.totalQuestions;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Trophy Icon with Glow
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    size: 80, color: AppColors.accent),
              ),
              const SizedBox(height: 30),
              if (_isNewRecord)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Yangi Rekord! 🎉",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentOrange,
                    ),
                  ),
                ),
              Text(
                percentage >= 0.8
                    ? "Mukammal!"
                    : (percentage >= 0.5 ? "Yaxshi!" : "Yana urinib ko'ring"),
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Siz ${widget.totalQuestions} ta savoldan ${widget.score} tasini topdingiz",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Center(
                  child: _buildStatCol(
                      "Sizning Ballingiz", "${widget.score}", isDark),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                            color: isDark ? Colors.white24 : Colors.black12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text("Menyu",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareResult,
                      icon: const Icon(Icons.share, size: 20),
                      label: Text("Ulashish",
                          style:
                              GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
