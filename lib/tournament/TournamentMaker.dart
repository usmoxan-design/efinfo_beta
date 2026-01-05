import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:efinfo_beta/tournament/TournamentEditor.dart';
import 'package:efinfo_beta/tournament/tournamentBracket.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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
    // Webda LateInitializationError oldini olish uchun plaginni oldindan uyg'otamiz
    try {
      FilePicker.platform;
    } catch (_) {}
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
        _tournaments[index] = tournament;
      } else {
        _tournaments.add(tournament);
      }
      _saveTournaments();
    });
  }

  void _confirmDelete(BuildContext context, TournamentModel tournament) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            "Turnirni o'chirishni tasdiqlang",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            "Siz rostdan ham \"${tournament.name}\" turnirini butunlay o'chirmoqchimisiz? Bu jarayonni ortga qaytarib bo'lmaydi.",
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Bekor qilish",
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.white54 : Colors.black54),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTournamentConfirmed(tournament);
              },
              child: Text(
                "O'chirish",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteTournamentConfirmed(TournamentModel tournament) {
    setState(() {
      _tournaments.removeWhere((t) => t.id == tournament.id);
      _saveTournaments();
    });
    _showSnackbar("Turnir o'chirildi: ${tournament.name}", Colors.red);
  }

  Future<void> _exportTournament(TournamentModel tournament) async {
    try {
      final String jsonString = jsonEncode(tournament.toJson());

      if (kIsWeb) {
        final Uri uri = Uri.parse(
            "data:application/json;charset=utf-8,${Uri.encodeComponent(jsonString)}");
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          _showSnackbar(
              "${tournament.name} nusxasi yuklab olindi", Colors.green);
          return;
        }
      }

      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));
      final xFile = XFile.fromData(
        bytes,
        mimeType: 'application/json',
        name: 'efinfo_${tournament.name.replaceAll(' ', '_')}.json',
      );

      await Share.shareXFiles(
        [xFile],
        text: "${tournament.name} - Turnir ma'lumotlari nusxasi",
      );
    } catch (e) {
      _showSnackbar("Eksport qilishda xatolik: $e", Colors.red);
    }
  }

  Future<void> _importTournaments() async {
    try {
      // Plaginni xavfsiz chaqirish
      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles(
          type: kIsWeb ? FileType.any : FileType.custom,
          allowedExtensions: kIsWeb ? null : ['json'],
          withData: true,
        );
      } catch (e) {
        // LateInitializationError yoki boshqa plagin xatolarini ushlash
        debugPrint("FilePicker error: $e");
        _showSnackbar(
            "Plagin yuklanishda xato. Sahifani qayta yangilang (Ctrl+F5)",
            Colors.red);
        return;
      }

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;

        // Webda fayl kengaytmasini qo'lda tekshiramiz
        if (kIsWeb &&
            platformFile.name.split('.').last.toLowerCase() != 'json') {
          _showSnackbar("Faqat .json fayllarini tanlang", Colors.orange);
          return;
        }

        if (platformFile.bytes == null) {
          _showSnackbar("Faylni o'qib bo'lmadi", Colors.red);
          return;
        }

        final String content = utf8.decode(platformFile.bytes!);
        final dynamic decodedData = jsonDecode(content);

        final List<TournamentModel> importedTournaments = [];
        if (decodedData is List) {
          importedTournaments.addAll(
            decodedData.map((json) =>
                TournamentModel.fromJson(json as Map<String, dynamic>)),
          );
        } else if (decodedData is Map<String, dynamic>) {
          importedTournaments.add(TournamentModel.fromJson(decodedData));
        }

        if (importedTournaments.isEmpty) {
          _showSnackbar("Faylda turnirlar topilmadi", Colors.orange);
          return;
        }

        // Tasdiqlash dialogni ko'rsatamiz
        if (!mounted) return;
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            final isDark =
                Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Text(
                "Importni tasdiqlang",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              content: Text(
                "${importedTournaments.length} ta turnir aniqlandi. Ularni joriy ro'yxatga qo'shishni xohlaysizmi?\n\n(Bir xil ID dagi turnirlar yangilanadi)",
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Bekor qilish",
                      style: GoogleFonts.outfit(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Import",
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF06DF5D),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );

        if (confirm == true) {
          setState(() {
            for (var imported in importedTournaments) {
              int index = _tournaments.indexWhere((t) => t.id == imported.id);
              if (index != -1) {
                _tournaments[index] = imported;
              } else {
                _tournaments.add(imported);
              }
            }
            _saveTournaments();
          });
          _showSnackbar(
              "${importedTournaments.length} ta turnir import qilindi",
              Colors.green);
        }
      }
    } catch (e) {
      debugPrint("Import error: $e");
      _showSnackbar("Import qilishda xatolik yuz berdi", Colors.red);
    }
  }

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF06DF5D)))
          : ListView.builder(
              padding: const EdgeInsets.only(
                  left: 12.0, right: 12.0, top: 12.0, bottom: 180.0),
              itemCount: _tournaments.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildAddTournamentCard(isDark);
                final tournament = _tournaments[index - 1];
                return _buildTournamentTile(tournament, isDark);
              },
            ),
    );
  }

  Widget _buildAddTournamentCard(bool isDark) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
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
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06DF5D).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      BoxIcons.bx_plus,
                      color: Color(0xFF06DF5D),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Yangi Turnir Yaratish",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "O'z turniringizni boshlang va natijalarni kuzatib boring",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Ma'lumotlarni import qilish",
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: BoxIcons.bx_import,
              label: "Import",
              color: const Color(0xFF06DF5D),
              onPressed: _importTournaments,
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTournamentTile(TournamentModel tournament, bool isDark) {
    String? championName;
    if (tournament.championId != null) {
      try {
        championName = tournament.teams
            .firstWhere((t) => t.id == tournament.championId)
            .name;
      } catch (_) {
        championName = null;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    tournament.name,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF06DF5D),
                    ),
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
                      : (tournament.isDrawDone ? Colors.green : Colors.orange),
                )
              ],
            ),
            const Divider(height: 24, color: Colors.white10),
            Row(
              children: [
                _buildInfoTag(
                  icon: BoxIcons.bx_group,
                  label: "${tournament.teams.length} jamoa",
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildInfoTag(
                  icon: BoxIcons.bx_grid_alt,
                  label: tournament.type == TournamentType.knockout
                      ? 'Knockout'
                      : 'League',
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              championName != null
                  ? "CHEMPION: $championName 👑"
                  : tournament.isDrawDone
                      ? "Holati: O'yinlarni kiriting"
                      : "Holati: Qura tashlanmagan",
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: championName != null
                    ? Colors.blueAccent
                    : (tournament.isDrawDone
                        ? Colors.greenAccent
                        : Colors.redAccent),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: BoxIcons.bx_show,
                  label: "Ko'rish",
                  color: Colors.blueAccent,
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TournamentBracketPage(tournament: tournament),
                      ),
                    );
                    if (result != null && result is TournamentModel) {
                      _addOrUpdateTournament(result);
                    }
                  },
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: BoxIcons.bx_edit,
                  label: "Ozgar",
                  color: Colors.grey,
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
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: BoxIcons.bx_export,
                  label: "",
                  color: Colors.blueAccent,
                  onPressed: () => _exportTournament(tournament),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: BoxIcons.bx_trash,
                  label: "",
                  color: Colors.redAccent,
                  onPressed: () => _confirmDelete(context, tournament),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(
      {required IconData icon, required String label, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.white70 : Colors.black54),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: label.isEmpty
          ? const SizedBox.shrink()
          : Text(
              label,
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        elevation: 0,
        padding: EdgeInsets.symmetric(
            horizontal: label.isEmpty ? 8 : 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }
}
