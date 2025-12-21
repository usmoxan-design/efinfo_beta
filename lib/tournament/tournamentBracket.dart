import 'package:confetti/confetti.dart';
import 'dart:typed_data';
import 'dart:ui';

import 'package:efinfo_beta/Others/imageSaver.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/tournament/match_model.dart';
import 'package:efinfo_beta/tournament/service/bracket_service.dart';
import 'package:efinfo_beta/tournament/service/league_service.dart';
import 'package:efinfo_beta/tournament/team_model.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:efinfo_beta/tournament/league_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'dart:math';

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
        int scoreA = match.scoreA;
        int scoreB = match.scoreB;
        final TextEditingController scoreAController =
            TextEditingController(text: scoreA.toString());
        final TextEditingController scoreBController =
            TextEditingController(text: scoreB.toString());

        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            "${match.teamA!.name} vs ${match.teamB!.name}",
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "${match.teamA!.name} Hisobi",
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                controller: scoreAController,
                onChanged: (value) => scoreA = int.tryParse(value) ?? 0,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: "${match.teamB!.name} Hisobi",
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                controller: scoreBController,
                onChanged: (value) => scoreB = int.tryParse(value) ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Bekor qilish",
                    style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
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
              child:
                  const Text("Saqlash", style: TextStyle(color: Colors.black)),
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

  List<Widget> _buildContent() {
    if (!_currentTournament.isDrawDone) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Qura tashlanmagan. Boshlash uchun tugmani bosing.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _performDraw,
                  icon: const Icon(BoxIcons.bx_dice_5),
                  label: const Text("Qura Tashlash"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
              ...currentRoundMatches
                  .toList()
                  .map((match) => _buildMatchCard(match, totalRounds)),
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
              _buildMatchCard(thirdPlaceMatch, totalRounds),
            ],
          ),
        ),
      );
    }

    return roundWidgets;
  }

  Widget _buildMatchCard(MatchModel match, int totalRounds) {
    bool hasWinner = match.winnerId != null;
    Color cardColor = match.round == 99
        ? Colors.orange[50]!
        : (hasWinner ? Colors.green[50]! : Colors.white);

    double width = 200;

    return InkWell(
      onTap: () => _editScore(match),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 4,
        color: cardColor,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTeamScore(
                  match.teamA, match.scoreA, hasWinner, match.winnerId),
              const Center(
                  child: Text("vs",
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.grey))),
              _buildTeamScore(
                  match.teamB, match.scoreB, hasWinner, match.winnerId),
              const Divider(height: 10),
              Center(
                child: Text(
                  hasWinner
                      ? "G'olib: ${match.winnerId == match.teamA?.id ? match.teamA?.name : match.teamB?.name}"
                      : (match.teamA != null && match.teamB != null
                          ? "Natijani kiriting"
                          : "Kutilmoqda"),
                  style: TextStyle(
                      color: hasWinner ? Colors.green : Colors.red,
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

  Widget _buildTeamScore(
      TeamModel? team, int score, bool hasWinner, String? winnerId) {
    if (team == null) {
      return const Text("TBD",
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
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
            style: TextStyle(
              fontWeight: isWinner ? FontWeight.w900 : FontWeight.w500,
              color: isWinner ? Colors.black : Colors.black87,
            ),
          ),
        ),
        Text(
          score.toString(),
          style: TextStyle(
            fontWeight: isWinner ? FontWeight.w900 : FontWeight.bold,
            color: isWinner ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_currentTournament.name),
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _currentTournament),
          ),
          actions: [
            if (championName != null)
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Center(
                  child: Text("🏆 G'olib: $championName",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent)),
                ),
              ),
            if (!_currentTournament.isDrawDone)
              IconButton(
                icon: const Icon(BoxIcons.bx_dice_5),
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
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black),
                  child: const Text("Saqlash"),
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
                            children: _buildContent(),
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
