// ... (Importlar TeamModel, MatchModel, TournamentModel va BracketService)
import 'dart:typed_data';
import 'dart:ui';

import 'package:efinfo_beta/Others/imageSaver.dart';
import 'package:efinfo_beta/additional/colors.dart';
import 'package:efinfo_beta/tournament/match_model.dart';
import 'package:efinfo_beta/tournament/service/bracket_service.dart';
import 'package:efinfo_beta/tournament/team_model.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:icons_plus/icons_plus.dart';
// Yordamchi fayl
// Yordamchi fayl
// Model fayli
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;

// JSON dan ma'lumotlarni yuklash uchun


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

  @override
  void initState() {
    super.initState();
    _currentTournament = widget.tournament;
    // Turnir boshlanishida 3-o'rin matchini tekshirish
    if (_currentTournament.isDrawDone) {
      // Bu yerda createThirdPlaceMatch faqat yarim finalchilar aniqlangandan keyin
      // ishlashi kerak, shuning uchun uni faqat natija kiritilganda chaqirish yaxshiroq.
      // Lekin agar initState da bo'lishi shart bo'lsa, qoldiramiz.
      _currentTournament =
          _bracketService.createThirdPlaceMatch(_currentTournament);
    }
  }

  // --- Natijani Tahrirlash (UI'dan servisga chaqirish) ---
  void _editScore(MatchModel match) {
    if (match.teamA == null || match.teamB == null) {
      _showSnackbar(
          "Match uchun jamoalar hali aniqlanmagan (TBD).", Colors.grey);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        // TextEditingController dialog yopilgandan keyin xotiradan o'chirilishi kerak
        // Bu joyda lokal o'zgaruvchilarni dialog ichida yaratish yaxshiroq
        int scoreA = match.scoreA;
        int scoreB = match.scoreB;
        final TextEditingController scoreAController =
            TextEditingController(text: scoreA.toString());
        final TextEditingController scoreBController =
            TextEditingController(text: scoreB.toString());

        // Bu obyektlar dialog yopilgandan so'ng avtomatik o'chiriladi.

        return AlertDialog(
          title: Text("${match.teamA!.name} vs ${match.teamB!.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration:
                    InputDecoration(labelText: "${match.teamA!.name} Hisobi"),
                keyboardType: TextInputType.number,
                controller: scoreAController,
                onChanged: (value) => scoreA = int.tryParse(value) ?? 0,
              ),
              TextField(
                decoration:
                    InputDecoration(labelText: "${match.teamB!.name} Hisobi"),
                keyboardType: TextInputType.number,
                controller: scoreBController,
                onChanged: (value) => scoreB = int.tryParse(value) ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Bekor qilish")),
            ElevatedButton(
              onPressed: () {
                try {
                  // reportMatchResult orqali natjani kiritish va updateBracket ni chaqirish
                  final updatedTournament = _bracketService.reportMatchResult(
                    _currentTournament,
                    match.id,
                    scoreA,
                    scoreB,
                  );
                  // 3-o'rin matchini yaratishni tekshirish (faqat Yarim Finaldan keyin)
                  final finalTournament =
                      _bracketService.createThirdPlaceMatch(updatedTournament);

                  // setState chaqiriladi
                  setState(() {
                    _currentTournament = finalTournament;
                    // Birinchi dialog yopiladi
                    Navigator.pop(context);
                    // Barcha o'zgarishlarni ListPage ga qaytarish
                    // Navigator.pop(context, _currentTournament);
                  });
                  _showSnackbar(
                      "Natija saqlandi. Bracket yangilandi.", Colors.green);
                } catch (e) {
                  _showSnackbar(
                      e.toString().replaceAll("Exception: ", ""), Colors.red);
                  Navigator.pop(context);
                }
              },
              child: const Text("Saqlash"),
            ),
          ],
        );
      },
    );
  }

  void _performDraw() {
    // Jamoalar sonini tekshirish
    final int teamCount = _currentTournament.teams.length;

    if (teamCount < 2) {
      _showSnackbar("Kamida 2 ta jamoa qo'shing!", Colors.red);
      return;
    }

    // if (teamCount > 16) {
    //   _showSnackbar("Jamoalar soni 16 tadan oshmasligi kerak!", Colors.red);
    //   return;
    // }

    // Turnir strukturasi uchun ideal sonlar tekshiruvi (2 yoki 4 ga bo'linadi)
    if (teamCount % 4 != 0 && teamCount != 2) {
      _showSnackbar(
        "Jamoalar soni 4 ga bo‘linadigan bo‘lishi bo‘lishi shart. Masalan: 2, 4, 8, 12, 16, 20.",
        Colors.red,
      );
      return;
    }

    try {
      final updatedTournament =
          _bracketService.createBracket(_currentTournament);
      setState(() {
        _currentTournament = updatedTournament;
        // Bosh sahifaga o'zgarishlarni qaytarish
        Navigator.pop(context, _currentTournament);
      });
      _showSnackbar("Qura muvaffaqiyatli tashlandi.", Colors.green);
    } catch (e) {
      String errorMsg = e.toString().replaceAll("Exception: ", "");
      print("Bracket error: $errorMsg");
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

  // --- UI Bosqichlari ---
  List<Widget> _buildBracket(BuildContext context) {
    if (!_currentTournament.isDrawDone) {
      // Qura tashlash tugmasi UI
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

    // Total rounds sonini BracketService dan olish
    // Math.log funksiyasini to'g'ri hisoblash uchun
    final totalRounds = log(BracketService.getNextPowerOfTwo(
            _currentTournament.teams.length)) ~/
        log(2);

    List<Widget> roundWidgets = [];

    // Asosiy Raundlar (1 dan Finalgacha)
    for (int r = 1; r <= totalRounds; r++) {
      // Raund bo'yicha Matchlarni ajratib olish
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
                  _bracketService.getRoundTitle(
                      r, totalRounds), // Dinamik raund nomi
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
              ),
              // Matchlarni chizish
              ...currentRoundMatches
                  .toList()
                  .map((match) => _buildMatchCard(match, totalRounds)),
            ],
          ),
        ),
      );
    }

    // 3-O'rin Uchrashuvi
    MatchModel? thirdPlaceMatch;
    // Round 99 - 3-o'rin uchun standart
    try {
      thirdPlaceMatch =
          _currentTournament.matches.firstWhere((m) => m.round == 99);
    } catch (_) {
      // Agar topilmasa, shunchaki o'tkazib yuboramiz.
    }

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

  // --- O'yin Natijasi Kartasi (UI) ---
  Widget _buildMatchCard(MatchModel match, int totalRounds) {
    bool hasWinner = match.winnerId != null;
    Color cardColor = match.round == 99
        ? Colors.orange[50]!
        : (hasWinner ? Colors.green[50]! : white);

    // Karta o'lchamini dinamik sozlash
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

  // --- Jamoa Natijasi UI ---
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

  // --- Main Build ---
  @override
  Widget build(BuildContext context) {
    final totalRounds = _currentTournament.teams.isNotEmpty
        ? log(BracketService.getNextPowerOfTwo(
                _currentTournament.teams.length)) ~/
            log(2)
        : 0;

    String? championName;
    if (totalRounds > 0) {
      MatchModel? finalMatch = _currentTournament.matches.firstWhere(
        (m) => m.round == totalRounds,
        orElse: () => MatchModel(id: '', round: 0),
      );

      if (finalMatch.winnerId != null && finalMatch.round != 0) {
        // Final g'olibini ID orqali topish
        try {
          championName = _currentTournament.teams
              .firstWhere((p) => p.id == finalMatch.winnerId)
              .name;
        } catch (_) {
          // G'olib topilmasa (kamdan-kam holat)
        }
      }
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

    return Scaffold(
      backgroundColor: const Color(0xFF011A0B),
      appBar: AppBar(
        title: Text("Turnir To'ri: ${_currentTournament.name}"),
        backgroundColor: blackColor,
        elevation: 0,
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
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.black),
                child: const Text("Saqlash"),
              ),
            )
        ],
      ),

      // >>>>>>>>>>> IKKI YO'NALISHLI SCROLL TUZATILGAN QISM <<<<<<<<<<<
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            // Ichki gorizontal skroll
            scrollDirection: Axis.horizontal,
            child: RepaintBoundary(
              key: pitchBoundaryKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildBracket(context),
              ),
            ),
          ),
        ),
      ),
      // >>>>>>>>>>> TUZATISH TUGADI <<<<<<<<<<<
    );
  }
}
