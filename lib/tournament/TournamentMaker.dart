import 'package:efinfo_beta/additional/colors.dart';
import 'package:efinfo_beta/tournament/TournamentEditor.dart';
import 'package:efinfo_beta/tournament/tournamentBracket.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TournamentListPage extends StatefulWidget {
  const TournamentListPage({super.key});

  @override
  State<TournamentListPage> createState() => _TournamentListPageState();
}

class _TournamentListPageState extends State<TournamentListPage> {
  List<TournamentModel> _tournaments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  // --- Saqlash/Yuklash Mantig'i ---

  Future<void> _loadTournaments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tournamentsString = prefs.getString('tournaments');

    if (tournamentsString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(tournamentsString);
        setState(() {
          _tournaments = jsonList
              .map((json) =>
                  TournamentModel.fromJson(json as Map<String, dynamic>))
              .toList();
        });
      } catch (e) {
        // Ma'lumotlar formatida xatolik bo'lsa, xato beradi
        _showSnackbar(
            "Saqlangan ma'lumotlarni yuklashda xatolik: $e", Colors.red);
        _tournaments = [];
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveTournaments() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        _tournaments.map((t) => t.toJson()).toList();
    await prefs.setString('tournaments', jsonEncode(jsonList));
  }

  void _addOrUpdateTournament(TournamentModel tournament) {
    setState(() {
      int index = _tournaments.indexWhere((t) => t.id == tournament.id);
      if (index != -1) {
        _tournaments[index] = tournament; // Tahrirlash
      } else {
        _tournaments.add(tournament); // Yangi qo'shish
      }
      _saveTournaments();
    });
  }

// Bu funksiyani o'chirish funksiyasi chaqiriladigan joyga qo'shing (odatda ListPage State'iga)
  void _confirmDelete(BuildContext context, TournamentModel tournament) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Turnirni o'chirishni tasdiqlang"),
          content: Text(
            "Siz rostdan ham \"${tournament.name}\" turnirini butunlay o'chirmoqchimisiz? Bu jarayonni ortga qaytarib bo'lmaydi.",
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            // 1. Bekor qilish tugmasi (Dialogni yopadi)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Bekor qilish"),
            ),
            // 2. O'chirishni tasdiqlash tugmasi
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Qizil rang bilan ogohlantirish
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dialogni yopish
                _deleteTournamentConfirmed(
                    tournament); // Haqiqiy o'chirishni chaqirish
              },
              child: const Text("O'chirish"),
            ),
          ],
        );
      },
    );
  }

// Haqiqiy o'chirish mantig'ini o'z ichiga olgan yangi funksiya
  void _deleteTournamentConfirmed(TournamentModel tournament) {
    setState(() {
      _tournaments.removeWhere((t) => t.id == tournament.id);
      _saveTournaments();
    });
    _showSnackbar("Turnir o'chirildi: ${tournament.name}", Colors.red);
  }

// Eski _deleteTournament o'rniga endi _confirmDelete ishlatilishi kerak:
// Sizning eski kodingizdan:
/*
void _deleteTournament(TournamentModel tournament) {
  setState(() {
    _tournaments.removeWhere((t) => t.id == tournament.id);
    _saveTournaments();
  });
  _showSnackbar("Turnir o'chirildi: ${tournament.name}", Colors.red);
}
*/
  void _showSnackbar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(milliseconds: 1500),
      ));
    }
  }

  // --- UI Yaratish ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("eFInfo Turnirchi"),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tournaments.isEmpty
              ? Center(
                  child: Text(
                    "Hozircha turnirlar yo'q.\nQo'shish tugmasini bosing.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: _tournaments.length,
                  itemBuilder: (context, index) {
                    final tournament = _tournaments[index];
                    return _buildTournamentTile(tournament);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TournamentEditorPage(),
            ),
          );
          if (result != null && result is TournamentModel) {
            _addOrUpdateTournament(result);
          }
        },
        label: const Text("Yangi Turnir"),
        icon: const Icon(BoxIcons.bx_plus),
        backgroundColor: mainColor,
      ),
    );
  }

  Widget _buildTournamentTile(TournamentModel tournament) {
    // Agar g'olib aniqlangan bo'lsa, ismini topish
    String? championName;
    if (tournament.championId != null) {
      try {
        championName = tournament.teams
            .firstWhere((t) => t.id == tournament.championId)
            .name;
      } catch (_) {
        championName = null; // G'olib topilmasa
      }
    }

    return InkWell(
      onTap: () async {
        // Turnir to'riga (Bracket) o'tish
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TournamentBracketPage(tournament: tournament),
          ),
        );
        if (result != null && result is TournamentModel) {
          _addOrUpdateTournament(result);
        }
      },
      child: Container(
        // elevation: 6,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),

        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tournament.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: mainColor,
                    ),
                  ),
                  Icon(
                    championName != null
                        ? Icons.emoji_events
                        : (tournament.isDrawDone
                            ? BoxIcons.bx_check_circle
                            : BoxIcons.bx_loader_circle),
                    color: championName != null
                        ? Colors.amber
                        : (tournament.isDrawDone
                            ? Colors.green
                            : Colors.orange),
                  )
                ],
              ),
              const Divider(height: 15),
              Text(
                "Ishtirokchilar: ${tournament.teams.length} ta jamoa",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 5),
              Text(
                championName != null
                    ? "CHEMPION: $championName 👑"
                    : tournament.isDrawDone
                        ? "Holati: Qura tashlangan. O'yinlarni kiriting."
                        : "Holati: Qura tashlanmagan. Tahrirlash mumkin.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: championName != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: championName != null
                      ? Colors.blue
                      : (tournament.isDrawDone
                          ? Colors.green
                          : Colors.redAccent),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Tahrirlash tugmasi
                  IconButton(
                    icon: const Icon(BoxIcons.bx_edit, color: Colors.blue),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TournamentEditorPage(tournament: tournament),
                        ),
                      );
                      if (result != null && result is TournamentModel) {
                        _addOrUpdateTournament(result);
                      }
                    },
                  ),
                  // O'chirish tugmasi
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        _confirmDelete(context, tournament), // YANGI FUNKSIYA
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
