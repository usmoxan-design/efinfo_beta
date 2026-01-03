import 'package:confetti/confetti.dart';
import 'dart:typed_data';
import 'dart:ui';

import 'package:efinfo_beta/Others/imageSaver.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/tournament/match_model.dart';
import 'package:efinfo_beta/tournament/service/bracket_service.dart';
import 'package:efinfo_beta/tournament/service/league_service.dart';
import 'package:efinfo_beta/tournament/team_model.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:efinfo_beta/tournament/league_table.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:provider/provider.dart';

class TournamentBracketPage extends StatefulWidget {
  final TournamentModel tournament;
  const TournamentBracketPage({super.key, required this.tournament});

  @override
  State<TournamentBracketPage> createState() => _TournamentBracketPageState();
}

class _TournamentBracketPageState extends State<TournamentBracketPage> {
  late TournamentModel _currentTournament;
  final BracketService _bracketService = BracketService();
  final LeagueService _leagueService = LeagueService();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    _currentTournament = widget.tournament;

    if (_currentTournament.isDrawDone &&
        _currentTournament.type == TournamentType.knockout) {
      _currentTournament =
          _bracketService.createThirdPlaceMatch(_currentTournament);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  int _calculateTotalRounds() {
    if (_currentTournament.teams.isEmpty) return 0;
    if (_currentTournament.type == TournamentType.league) {
      if (_currentTournament.matches.isEmpty) return 0;
      return _currentTournament.matches
          .map((m) => m.round)
          .reduce((a, b) => a > b ? a : b);
    }
    return log(BracketService.getNextPowerOfTwo(
            _currentTournament.teams.length)) ~/
        log(2);
  }

  void _editScore(MatchModel match) {
    if (match.teamA == null || match.teamB == null) {
      _showSnackbar(
          "Match uchun jamoalar hali aniqlanmagan (TBD).", Colors.grey);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
        int scoreA = match.scoreA;
        int scoreB = match.scoreB;
        final TextEditingController scoreAController =
            TextEditingController(text: scoreA.toString());
        final TextEditingController scoreBController =
            TextEditingController(text: scoreB.toString());

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            "${match.teamA!.name} vs ${match.teamB!.name}",
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "${match.teamA!.name} Hisobi",
                  labelStyle: GoogleFonts.outfit(
                      color: isDark ? Colors.white54 : Colors.black54),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12)),
                ),
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : Colors.black),
                keyboardType: TextInputType.number,
                controller: scoreAController,
                onChanged: (value) => scoreA = int.tryParse(value) ?? 0,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: "${match.teamB!.name} Hisobi",
                  labelStyle: GoogleFonts.outfit(
                      color: isDark ? Colors.white54 : Colors.black54),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12)),
                ),
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : Colors.black),
                keyboardType: TextInputType.number,
                controller: scoreBController,
                onChanged: (value) => scoreB = int.tryParse(value) ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Bekor qilish",
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white38 : Colors.black38))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06DF5D),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                try {
                  TournamentModel updatedTournament;
                  if (_currentTournament.type == TournamentType.knockout) {
                    updatedTournament = _bracketService.reportMatchResult(
                      _currentTournament,
                      match.id,
                      scoreA,
                      scoreB,
                    );
                    updatedTournament = _bracketService
                        .createThirdPlaceMatch(updatedTournament);
                  } else {
                    updatedTournament = _leagueService.reportMatchResult(
                      _currentTournament,
                      match.id,
                      scoreA,
                      scoreB,
                    );
                  }

                  setState(() {
                    _currentTournament = updatedTournament;
                    Navigator.pop(context);
                  });

                  bool isFinished = false;
                  if (_currentTournament.type == TournamentType.knockout) {
                    int totalRounds = _calculateTotalRounds();
                    if (match.round == totalRounds &&
                        updatedTournament.matches
                                .firstWhere((m) => m.id == match.id)
                                .winnerId !=
                            null) {
                      isFinished = true;
                    }
                  } else {
                    isFinished =
                        _currentTournament.matches.every((m) => m.isPlayed);
                  }

                  if (isFinished) {
                    _confettiController.play();
                    _showSnackbar("Turnir g'olibi aniqlandi! 🏆", Colors.amber);
                  } else {
                    _showSnackbar("Natija saqlandi.", Colors.green);
                  }
                } catch (e) {
                  _showSnackbar(
                      e.toString().replaceAll("Exception: ", ""), Colors.red);
                  Navigator.pop(context);
                }
              },
              child: Text("Saqlash",
                  style: GoogleFonts.outfit(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _performDraw() {
    final int teamCount = _currentTournament.teams.length;

    if (teamCount < 2) {
      _showSnackbar("Kamida 2 ta jamoa qo'shing!", Colors.red);
      return;
    }

    if (_currentTournament.type == TournamentType.knockout) {
      if (teamCount % 4 != 0 && teamCount != 2) {
        _showSnackbar(
          "Knockout uchun jamoalar soni 4 ga bo‘linadigan bo‘lishi shart. Masalan: 2, 4, 8, 12, 16.",
          Colors.red,
        );
        return;
      }
    }

    try {
      TournamentModel updatedTournament;
      if (_currentTournament.type == TournamentType.knockout) {
        updatedTournament = _bracketService.createBracket(_currentTournament);
      } else {
        updatedTournament = _leagueService.createLeague(_currentTournament);
      }

      setState(() {
        _currentTournament = updatedTournament;
        // Bosh sahifaga o'zgarishlarni qaytarish
        // Note: Navigator.pop(context, _currentTournament) replaces the whole state in TournamentListPage
      });
      _showSnackbar("Qura muvaffaqiyatli tashlandi.", Colors.green);
    } catch (e) {
      String errorMsg = e.toString().replaceAll("Exception: ", "");
      _showSnackbar("Xato: $errorMsg", Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(milliseconds: 2000),
    ));
  }

  List<Widget> _buildContent(bool isDark) {
    if (!_currentTournament.isDrawDone) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Qura tashlanmagan. Boshlash uchun tugmani bosing.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      color: isDark ? Colors.white38 : Colors.black38),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _performDraw,
                  icon: const Icon(BoxIcons.bx_dice_5, color: Colors.black),
                  label: Text("Qura Tashlash",
                      style: GoogleFonts.outfit(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06DF5D),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        )
      ];
    }

    if (_currentTournament.type == TournamentType.league) {
      return [
        LeagueTableWidget(
          tournament: _currentTournament,
          onMatchTap: (match) => _editScore(match),
        )
      ];
    }

    final totalRounds = log(BracketService.getNextPowerOfTwo(
            _currentTournament.teams.length)) ~/
        log(2);

    List<Widget> roundWidgets = [];

    for (int r = 1; r <= totalRounds; r++) {
      List<MatchModel> currentRoundMatches =
          _currentTournament.matches.where((m) => m.round == r).toList();

      if (currentRoundMatches.isEmpty) continue;

      roundWidgets.add(
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  _bracketService.getRoundTitle(r, totalRounds),
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF06DF5D),
                  ),
                ),
              ),
              ...currentRoundMatches
                  .toList()
                  .map((match) => _buildMatchCard(match, totalRounds, isDark)),
            ],
          ),
        ),
      );
    }

    MatchModel? thirdPlaceMatch;
    try {
      thirdPlaceMatch =
          _currentTournament.matches.firstWhere((m) => m.round == 99);
    } catch (_) {}

    if (thirdPlaceMatch != null) {
      roundWidgets.add(
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  _bracketService.getRoundTitle(99, totalRounds),
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
              _buildMatchCard(thirdPlaceMatch, totalRounds, isDark),
            ],
          ),
        ),
      );
    }

    return roundWidgets;
  }

  Widget _buildMatchCard(MatchModel match, int totalRounds, bool isDark) {
    bool hasWinner = match.winnerId != null;

    double width = 200;

    return InkWell(
      onTap: () => _editScore(match),
      child: GlassContainer(
        margin: const EdgeInsets.symmetric(vertical: 8),
        borderRadius: 16,
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTeamScore(
                  match.teamA, match.scoreA, hasWinner, match.winnerId, isDark),
              Center(
                  child: Text("vs",
                      style: GoogleFonts.outfit(
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white24 : Colors.black26,
                          fontSize: 12))),
              _buildTeamScore(
                  match.teamB, match.scoreB, hasWinner, match.winnerId, isDark),
              Divider(
                  height: 10, color: isDark ? Colors.white10 : Colors.black12),
              Center(
                child: Text(
                  hasWinner
                      ? "G'olib: ${match.winnerId == match.teamA?.id ? match.teamA?.name : match.teamB?.name}"
                      : (match.teamA != null && match.teamB != null
                          ? "Natijani kiriting"
                          : "Kutilmoqda"),
                  style: GoogleFonts.outfit(
                      color: hasWinner
                          ? const Color(0xFF06DF5D)
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamScore(TeamModel? team, int score, bool hasWinner,
      String? winnerId, bool isDark) {
    if (team == null) {
      return Text("TBD",
          style: GoogleFonts.outfit(
              color: isDark ? Colors.white38 : Colors.black38,
              fontStyle: FontStyle.italic));
    }

    bool isWinner = hasWinner && team.id == winnerId;

    return Row(
      children: [
        Icon(
          isWinner ? Icons.emoji_events : Icons.people,
          color: isWinner ? Colors.amber : team.color,
          size: 18,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            team.name,
            style: GoogleFonts.outfit(
              fontWeight: isWinner ? FontWeight.w900 : FontWeight.w500,
              color: isWinner
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
        Text(
          score.toString(),
          style: GoogleFonts.outfit(
            fontWeight: isWinner ? FontWeight.w900 : FontWeight.bold,
            color: isWinner
                ? const Color(0xFF06DF5D)
                : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    String? championName;
    if (_currentTournament.championId != null) {
      try {
        championName = _currentTournament.teams
            .firstWhere((p) => p.id == _currentTournament.championId)
            .name;
      } catch (_) {}
    }

    final GlobalKey pitchBoundaryKey = GlobalKey();

    Future<void> captureAndSave() async {
      final RenderRepaintBoundary boundary = pitchBoundaryKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List? bytes = byteData?.buffer.asUint8List();

      if (bytes != null) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ImagePreviewScreen(imageBytes: bytes),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Rasmga olishda xato yuz berdi."),
                backgroundColor: Colors.red),
          );
        }
      }
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _currentTournament);
        return false;
      },
      child: Scaffold(
        backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            _currentTournament.name,
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.pop(context, _currentTournament),
          ),
          actions: [
            if (championName != null)
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Center(
                  child: Text("🏆 G'olib: $championName",
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent)),
                ),
              ),
            if (!_currentTournament.isDrawDone)
              IconButton(
                icon: Icon(BoxIcons.bx_dice_5,
                    color: isDark ? Colors.white : Colors.black),
                onPressed: _performDraw,
                tooltip: "Qura tashlash",
              ),
            const SizedBox(width: 10),
            if (_currentTournament.isDrawDone)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ElevatedButton(
                  onPressed: captureAndSave,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06DF5D),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text("Saqlash",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              )
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _currentTournament.type == TournamentType.league &&
                        _currentTournament.isDrawDone
                    ? RepaintBoundary(
                        key: pitchBoundaryKey,
                        child: LeagueTableWidget(
                          tournament: _currentTournament,
                          onMatchTap: (match) => _editScore(match),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: RepaintBoundary(
                          key: pitchBoundaryKey,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildContent(isDark),
                          ),
                        ),
                      ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
