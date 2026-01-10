import 'dart:async';
import 'package:efinfo_beta/quiz/quiz_data.dart';
import 'package:efinfo_beta/quiz/quiz_result_page.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class QuizGamePage extends StatefulWidget {
  final String? league;
  const QuizGamePage({super.key, this.league});

  @override
  State<QuizGamePage> createState() => _QuizGamePageState();
}

class _QuizGamePageState extends State<QuizGamePage>
    with TickerProviderStateMixin {
  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _hasAnswered = false;

  // Timer
  Timer? _timer;
  int _timeLeft = 15;
  static const int _maxTime = 15;

  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _startQuiz();
  }

  void _startQuiz() {
    setState(() {
      _questions = QuizData.getQuestions(10, league: widget.league);
      _isLoading = false;
      _currentIndex = 0;
      _score = 0;
      _hasAnswered = false;
      _selectedOption = null;
    });
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = _maxTime;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _handleTimeOut();
      }
    });
  }

  void _handleTimeOut() {
    if (_hasAnswered) return;
    _onAnswerSelected(null); // Null means timeout/wrong
  }

  void _onAnswerSelected(String? selectedOption) async {
    if (_hasAnswered) return;

    _timer?.cancel();
    setState(() {
      _hasAnswered = true;
      _selectedOption = selectedOption;
    });

    bool isCorrect = false;
    if (selectedOption != null) {
      isCorrect = selectedOption == _questions[_currentIndex].correctAnswer;
    }

    if (isCorrect) {
      _score++;
    } else {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 200);
      }
    }

    // Wait and go next
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      if (_currentIndex < _questions.length - 1) {
        if (mounted) {
          setState(() {
            _currentIndex++;
            _hasAnswered = false;
            _selectedOption = null;
          });
          _startTimer();
        }
      } else {
        _endQuiz();
      }
    });
  }

  void _endQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultPage(
          score: _score,
          totalQuestions: _questions.length,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const CloseButton(),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                "Savollar topilmadi",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Iltimos keyinroq urinib ko'ring yoki internetni tekshiring.",
                style: GoogleFonts.outfit(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CloseButton(),
        title: Text(
          "Savol ${_currentIndex + 1}/10",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _timeLeft <= 5 ? AppColors.error : AppColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$_timeLeft s",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.2,
                  colors: [
                    const Color(0xFF1A1A2E),
                    AppColors.background,
                  ],
                )
              : null,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  borderRadius: BorderRadius.circular(4),
                ),
                const Spacer(),

                // Image container
                Center(
                  child: Hero(
                    tag: 'quiz_image',
                    child: Container(
                      height: 200,
                      width: 200,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        question.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Qaysi klub?",
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                // Options
                ...question.options.map((option) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OptionButton(
                      text: option,
                      state: _getOptionState(option, question),
                      onTap: () => _onAnswerSelected(option),
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  OptionState _getOptionState(String option, QuizQuestion question) {
    if (!_hasAnswered) return OptionState.neutral;
    if (option == question.correctAnswer) return OptionState.correct;
    if (option == _selectedOption) return OptionState.wrong;
    return OptionState.neutral;
  }
}

enum OptionState { neutral, correct, wrong }

class _OptionButton extends StatelessWidget {
  final String text;
  final OptionState state;
  final VoidCallback onTap;

  const _OptionButton({
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    Color bgColor;
    Color textColor;
    BorderSide border;

    switch (state) {
      case OptionState.correct:
        bgColor = AppColors.accent; // Green
        textColor = Colors.white;
        border = BorderSide.none;
        break;
      case OptionState.wrong:
        bgColor = AppColors.error;
        textColor = Colors.white;
        border = BorderSide.none;
        break;
      case OptionState.neutral:
        bgColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
        textColor = isDark ? Colors.white : Colors.black;
        border = BorderSide(
            color: isDark ? Colors.white24 : Colors.grey[300]!, width: 1);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.fromBorderSide(border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (state == OptionState.correct)
              const Icon(Icons.check_circle, color: Colors.white),
            if (state == OptionState.wrong)
              const Icon(Icons.cancel, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
