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

  // New word game state
  List<String?> _currentGuess = [];
  List<String> _availableLetters = [];
  List<int?> _usedIndices =
      []; // Stores the index in _availableLetters for each slot in _currentGuess
  Set<int> _hintIndices = {}; // Indices that are pre-filled as hints

  // Timer
  Timer? _timer;
  int _timeLeft = 30; // More time for word game
  static const int _maxTime = 30;

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  void _initQuiz() {
    _questions = QuizData.getQuestions(10, league: widget.league);
    if (_questions.isNotEmpty) {
      _setupLevel();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _setupLevel() {
    String answer = _questions[_currentIndex].correctAnswer.toUpperCase();
    _currentGuess = List.generate(answer.length, (index) => null);
    _usedIndices = List.generate(answer.length, (index) => null);
    _hintIndices = {};

    // 1. Identify letters and spaces
    List<int> letterIndices = [];
    for (int i = 0; i < answer.length; i++) {
      if (answer[i] == ' ') {
        _currentGuess[i] = ' ';
      } else {
        letterIndices.add(i);
      }
    }

    // 2. Reveal hints (~30% of letters)
    letterIndices.shuffle();
    int hintCount = (letterIndices.length * 0.3).round();
    if (hintCount == 0 && letterIndices.isNotEmpty) hintCount = 1;

    for (int i = 0; i < hintCount; i++) {
      int index = letterIndices[i];
      _currentGuess[index] = answer[index];
      _hintIndices.add(index);
    }

    // 3. Prepare available letters (only for non-hint letters)
    List<String> neededLetters = [];
    for (int i = 0; i < answer.length; i++) {
      if (answer[i] != ' ' && !_hintIndices.contains(i)) {
        neededLetters.add(answer[i]);
      }
    }

    // Add decoys
    const String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    final random = DateTime.now().millisecond;
    int decoyCount = neededLetters.length < 8 ? 4 : 2;
    for (int i = 0; i < decoyCount; i++) {
      neededLetters.add(alphabet[(random + i) % 26]);
    }

    neededLetters.shuffle();
    _availableLetters = neededLetters;
    _hasAnswered = false;
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = _maxTime;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        if (mounted) {
          setState(() {
            _timeLeft--;
          });
        }
      } else {
        _handleTimeOut();
      }
    });
  }

  void _handleTimeOut() {
    if (_hasAnswered) return;
    _finishLevel(false);
  }

  void _onLetterTap(int index) {
    if (_hasAnswered) return;

    // Find first empty slot (null)
    int emptyIndex = -1;
    for (int i = 0; i < _currentGuess.length; i++) {
      if (_currentGuess[i] == null) {
        emptyIndex = i;
        break;
      }
    }

    if (emptyIndex != -1) {
      setState(() {
        _currentGuess[emptyIndex] = _availableLetters[index];
        _usedIndices[emptyIndex] = index;
      });

      // Check if finished
      if (!_currentGuess.contains(null)) {
        _checkAnswer();
      }
    }
  }

  void _onSlotTap(int index) {
    if (_hasAnswered) return;
    if (_currentGuess[index] == null ||
        _currentGuess[index] == ' ' ||
        _hintIndices.contains(index)) return;

    setState(() {
      _currentGuess[index] = null;
      _usedIndices[index] = null;
    });
  }

  void _checkAnswer() async {
    String guess = _currentGuess.join('').toUpperCase();
    String answer = _questions[_currentIndex].correctAnswer.toUpperCase();

    if (guess == answer) {
      _finishLevel(true);
    } else {
      // Wrong guess - maybe shake or vibrate
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 200);
      }
      // Optional: Clear or show error
    }
  }

  void _finishLevel(bool isCorrect) {
    if (_hasAnswered) return;
    _timer?.cancel();
    setState(() {
      _hasAnswered = true;
    });

    if (isCorrect) {
      _score++;
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (_currentIndex < _questions.length - 1) {
        if (mounted) {
          setState(() {
            _currentIndex++;
            _setupLevel();
          });
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
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text("Savollar topilmadi")),
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
          "O'yinchi ${_currentIndex + 1}/10",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _timeLeft <= 7 ? AppColors.error : AppColors.accent,
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
                  colors: [const Color(0xFF1A1A2E), AppColors.background],
                )
              : null,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              // Image
              Center(
                child: Container(
                  height: 180,
                  width: 180,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
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
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Slots
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 10,
                  children: List.generate(_currentGuess.length, (index) {
                    String? char = _currentGuess[index];
                    if (char == ' ') {
                      return const SizedBox(width: 20, height: 40);
                    }
                    bool isHint = _hintIndices.contains(index);
                    return GestureDetector(
                      onTap: () => _onSlotTap(index),
                      child: Container(
                        width: 35,
                        height: 45,
                        decoration: BoxDecoration(
                          color: isHint
                              ? (isDark
                                  ? AppColors.accent.withOpacity(0.2)
                                  : AppColors.accent.withOpacity(0.1))
                              : (isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isHint
                                ? AppColors.accent
                                : (char != null
                                    ? (isDark ? Colors.white70 : Colors.black45)
                                    : (isDark
                                        ? Colors.white24
                                        : Colors.grey[300]!)),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            char ?? "•",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isHint
                                  ? AppColors.accent
                                  : (isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(),
              // Letter Bank
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(_availableLetters.length, (index) {
                    bool isUsed = _usedIndices.contains(index);
                    return GestureDetector(
                      onTap: isUsed ? null : () => _onLetterTap(index),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isUsed ? 0.3 : 1.0,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isUsed
                                ? null
                                : [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2))
                                  ],
                          ),
                          child: Center(
                            child: Text(
                              _availableLetters[index],
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
