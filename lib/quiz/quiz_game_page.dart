import 'dart:async';
import 'dart:math';
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
  final String mode; // 'Oson', 'Standart', 'Qiyin'
  const QuizGamePage({super.key, this.league, this.mode = 'Standart'});

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
  bool _isChecking = false; // When user clicks 'Next'
  bool _isWrong = false; // To show correct answer in red if they failed

  // Power-ups (Current counts for the whole session)
  int _hintsUsed = 0;
  int _clearsUsed = 0;
  static const int _maxPowerUps = 2;

  // Timer
  Timer? _timer;
  int _timeLeft = 45; // More time for word game
  static const int _maxTime = 45;

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  String _sanitizeName(String name) {
    // Keep only A-Z and spaces, remove accents/numbers
    return name
        .toUpperCase()
        .replaceAll(RegExp(r'[0-9\W_]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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
    String originalName = _questions[_currentIndex].correctAnswer;
    String answer = _sanitizeName(originalName);

    _currentGuess = List.generate(answer.length, (index) => null);
    _usedIndices = List.generate(answer.length, (index) => null);
    _hintIndices = {};
    _isChecking = false;
    _isWrong = false;

    // 1. Identify letters and spaces
    List<int> letterIndices = [];
    for (int i = 0; i < answer.length; i++) {
      if (answer[i] == ' ') {
        _currentGuess[i] = ' ';
      } else {
        letterIndices.add(i);
      }
    }

    // 2. Initial hinting based on mode
    double hintRatio;
    int maxConsecutive;
    switch (widget.mode) {
      case 'Oson':
        hintRatio = 0.6;
        maxConsecutive = 1;
        break;
      case 'Ekstremal':
        hintRatio = 0.0;
        maxConsecutive = 100; // No forced reveals
        break;
      case 'Qiyin':
        hintRatio = 0.15;
        maxConsecutive = 4;
        break;
      default: // Standart
        hintRatio = 0.3;
        maxConsecutive = 2;
        break;
    }

    List<int> tempIndices = List.from(letterIndices)..shuffle();
    int hintCount = (letterIndices.length * hintRatio).round();
    if (hintCount == 0 && letterIndices.isNotEmpty) hintCount = 1;
    for (int i = 0; i < hintCount; i++) {
      _hintIndices.add(tempIndices[i]);
    }

    // 3. Constraint: Max consecutive dots
    int consecutiveHidden = 0;
    for (int i = 0; i < answer.length; i++) {
      if (answer[i] != ' ' && !_hintIndices.contains(i)) {
        consecutiveHidden++;
        if (consecutiveHidden > maxConsecutive) {
          _hintIndices.add(i);
          consecutiveHidden = 0;
        }
      } else {
        consecutiveHidden = 0;
      }
    }

    // Apply hints to current guess
    for (int idx in _hintIndices) {
      _currentGuess[idx] = answer[idx];
    }

    // 4. Prepare available letters
    List<String> neededLetters = [];
    for (int i = 0; i < answer.length; i++) {
      if (answer[i] != ' ' && !_hintIndices.contains(i)) {
        neededLetters.add(answer[i]);
      }
    }

    // Add decoys (extra letters)
    const String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    final random = Random();
    int decoyCount = neededLetters.length < 6 ? 6 : 4;
    for (int i = 0; i < decoyCount; i++) {
      neededLetters.add(alphabet[random.nextInt(26)]);
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
    _autoCheck();
  }

  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 200);
    }
  }

  void _onLetterTap(int index) {
    if (_hasAnswered || _isChecking) return;

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

      // Auto-check if full
      if (!_currentGuess.contains(null)) {
        _autoCheck();
      }
    }
  }

  void _onSlotTap(int index) {
    if (_hasAnswered || _isChecking) return;
    if (_currentGuess[index] == null ||
        _currentGuess[index] == ' ' ||
        _hintIndices.contains(index)) return;

    setState(() {
      _currentGuess[index] = null;
      _usedIndices[index] = null;
    });
  }

  void _use5050() {
    if (widget.mode == 'Oson' ||
        _hintsUsed >= _maxPowerUps ||
        _isChecking ||
        _hasAnswered) return;

    String answer = _sanitizeName(_questions[_currentIndex].correctAnswer);
    List<int> emptyIndices = [];
    for (int i = 0; i < _currentGuess.length; i++) {
      if (_currentGuess[i] == null) emptyIndices.add(i);
    }

    if (emptyIndices.isEmpty) return;

    setState(() {
      _hintsUsed++;
      int revealCount = (emptyIndices.length / 2).ceil();
      emptyIndices.shuffle();
      for (int i = 0; i < revealCount; i++) {
        int idx = emptyIndices[i];
        String char = answer[idx];
        _currentGuess[idx] = char;
        _hintIndices.add(idx);
      }
      // Re-prepare bank
      List<String> newBank = [];
      for (int i = 0; i < answer.length; i++) {
        if (answer[i] != ' ' && !_hintIndices.contains(i)) {
          newBank.add(answer[i]);
        }
      }
      const String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
      final random = Random();
      for (int i = 0; i < 4; i++) newBank.add(alphabet[random.nextInt(26)]);
      newBank.shuffle();

      _availableLetters = newBank;
      _usedIndices = List.generate(_currentGuess.length, (index) => null);
    });
  }

  void _removeDecoys() {
    if (widget.mode == 'Oson' ||
        _clearsUsed >= _maxPowerUps ||
        _isChecking ||
        _hasAnswered) return;

    String answer = _sanitizeName(_questions[_currentIndex].correctAnswer);
    setState(() {
      _clearsUsed++;
      List<String> needed = [];
      for (int i = 0; i < answer.length; i++) {
        if (answer[i] != ' ' && !_hintIndices.contains(i)) {
          needed.add(answer[i]);
        }
      }
      needed.shuffle();
      _availableLetters = needed;
      _usedIndices = List.generate(_currentGuess.length, (index) => null);
      for (int i = 0; i < _currentGuess.length; i++) {
        if (!_hintIndices.contains(i) && _currentGuess[i] != ' ') {
          _currentGuess[i] = null;
        }
      }
    });
  }

  void _autoCheck({bool forceWrong = false}) {
    if (_isChecking || _hasAnswered) return;

    _timer?.cancel();
    setState(() {
      _isChecking = true;
    });

    String guess = _currentGuess.join('').toUpperCase();
    String answer =
        _sanitizeName(_questions[_currentIndex].correctAnswer).toUpperCase();

    bool isCorrect = !forceWrong && (guess == answer);

    if (isCorrect) {
      _finishLevel(true);
    } else {
      setState(() {
        _isWrong = true;
      });
      _vibrate();
      _finishLevel(false);
    }
  }

  void _finishLevel(bool isCorrect) {
    if (_hasAnswered) return;

    if (isCorrect) {
      _score++;
    }

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        if (_currentIndex < _questions.length - 1) {
          setState(() {
            _currentIndex++;
            _setupLevel();
          });
        } else {
          setState(() {
            _hasAnswered = true;
          });
          _endQuiz();
        }
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
          mode: widget.mode,
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
        title: Column(
          children: [
            Text(
              "O'yinchi ${_currentIndex + 1}/10",
              style:
                  GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              widget.mode,
              style: GoogleFonts.outfit(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: (_isChecking || _hasAnswered)
                ? null
                : () => _autoCheck(forceWrong: true),
            icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
            tooltip: "Topa olmadim",
          ),
          if (widget.mode != 'Oson') ...[
            _PowerUpIcon(
              icon: Icons.lightbulb_outline,
              count: _maxPowerUps - _hintsUsed,
              onTap: _use5050,
              isActive: _hintsUsed < _maxPowerUps && !_isChecking,
            ),
            _PowerUpIcon(
              icon: Icons.auto_fix_high,
              count: _maxPowerUps - _clearsUsed,
              onTap: _removeDecoys,
              isActive: _clearsUsed < _maxPowerUps && !_isChecking,
            ),
          ],
          Container(
            margin:
                const EdgeInsets.only(right: 16, left: 8, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _timeLeft <= 7 ? AppColors.error : AppColors.accent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              "$_timeLeft s",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
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
                  padding: const EdgeInsets.all(12),
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
                      return const SizedBox(width: 15, height: 40);
                    }
                    bool isHint = _hintIndices.contains(index);
                    return GestureDetector(
                      onTap: () => _onSlotTap(index),
                      child: Container(
                        width: 32,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isHint
                              ? (isDark
                                  ? AppColors.accent.withOpacity(0.2)
                                  : AppColors.accent.withOpacity(0.1))
                              : (_isWrong
                                  ? (isDark
                                      ? AppColors.error.withOpacity(0.2)
                                      : AppColors.error.withOpacity(0.1))
                                  : (isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.white)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isWrong
                                ? AppColors.error
                                : (isHint
                                    ? AppColors.accent
                                    : (char != null && char != "•"
                                        ? (_isChecking
                                            ? AppColors.accent
                                            : (isDark
                                                ? Colors.white70
                                                : Colors.black45))
                                        : (isDark
                                            ? Colors.white24
                                            : Colors.grey[300]!))),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            char ?? "•",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isWrong
                                  ? AppColors.error
                                  : (isHint
                                      ? AppColors.accent
                                      : (isDark ? Colors.white : Colors.black)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              const Spacer(),
              // Letter Bank
              if (!_isChecking)
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_availableLetters.length, (index) {
                      bool isUsed = _usedIndices.contains(index);
                      return GestureDetector(
                        onTap: (isUsed || _isChecking)
                            ? null
                            : () => _onLetterTap(index),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isUsed ? 0.2 : 1.0,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                _availableLetters[index],
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
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
              if (_isChecking && !_isWrong)
                const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                ),
              if (_isWrong)
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text("Xato! Keyingisiga o'tilmoqda...",
                      style: GoogleFonts.outfit(color: AppColors.error)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PowerUpIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onTap;
  final bool isActive;

  const _PowerUpIcon({
    required this.icon,
    required this.count,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.grey, size: 20),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
