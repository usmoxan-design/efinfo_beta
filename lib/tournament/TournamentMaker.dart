import 'package:efinfo_beta/services/auth_service.dart';
import 'package:efinfo_beta/services/online_tournament_service.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:efinfo_beta/tournament/TournamentEditor.dart';
import 'package:efinfo_beta/tournament/tournamentBracket.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:efinfo_beta/tournament/OnlineTournamentLobbyPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class TournamentListPage extends StatefulWidget {
  const TournamentListPage({super.key});

  @override
  State<TournamentListPage> createState() => _TournamentListPageState();
}

class _TournamentListPageState extends State<TournamentListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF06DF5D),
            labelColor: isDark ? Colors.white : Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Onlayn"),
              Tab(text: "Oflayn"),
              Tab(text: "Arxiv"),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OnlineTournamentTab(),
          OfflineTournamentTab(),
          ArchiveTournamentTab(),
        ],
      ),
    );
  }
}

class OfflineTournamentTab extends StatefulWidget {
  const OfflineTournamentTab({super.key});

  @override
  State<OfflineTournamentTab> createState() => _OfflineTournamentTabState();
}

class _OfflineTournamentTabState extends State<OfflineTournamentTab> {
  List<TournamentModel> _tournaments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
    try {
      FilePicker.platform;
    } catch (_) {}
  }

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
        _tournaments = [];
      }
    }
    setState(() => _isLoading = false);
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
      builder: (context) => AlertDialog(
        title: const Text("Turnirni o'chirish"),
        content: Text("${tournament.name}ni o'chirasizmi?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Yo'q")),
          TextButton(
              onPressed: () {
                setState(() {
                  _tournaments.removeWhere((t) => t.id == tournament.id);
                  _saveTournaments();
                });
                Navigator.pop(context);
              },
              child: const Text("Ha", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _loadTournaments,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
        itemCount: _tournaments.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildAddCard(isDark);
          return _buildTile(_tournaments[index - 1], isDark);
        },
      ),
    );
  }

  Widget _buildAddCard(bool isDark) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TournamentEditorPage()));
        if (result != null && result is TournamentModel)
          _addOrUpdateTournament(result);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(BoxIcons.bx_plus, color: Color(0xFF06DF5D), size: 32),
              const SizedBox(height: 8),
              Text("Yangi Oflayn Turnir",
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(TournamentModel t, bool isDark) {
    String statusText = t.isCompleted
        ? "Tugallangan"
        : (!t.isDrawDone ? "Qura tashlanmagan" : "O'yinlarni kiriting");
    Color statusColor = t.isCompleted
        ? Colors.blue
        : (!t.isDrawDone ? Colors.redAccent : const Color(0xFF06DF5D));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.name,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF06DF5D),
                    )),
                Icon(
                    t.isCompleted
                        ? Icons.check_circle_rounded
                        : (t.isDrawDone
                            ? Icons.check_circle_outline
                            : Icons.pending_outlined),
                    color: statusColor,
                    size: 28),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: isDark ? Colors.white10 : Colors.black12),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildChip(
                    "${t.teams.length} jamoa", Icons.people_outline, isDark),
                const SizedBox(width: 10),
                _buildChip(t.typeString, Icons.grid_view_rounded, isDark),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Holati: $statusText",
              style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: statusColor,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TouchableButton(
                    onPressed: () async {
                      final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  TournamentBracketPage(tournament: t)));
                      if (res != null && res is TournamentModel)
                        _addOrUpdateTournament(res);
                    },
                    color: const Color(0xFF1E3A5F),
                    icon: Icons.visibility_outlined,
                    label: "Ko'rish",
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TouchableButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  TournamentEditorPage(tournament: t)));
                      if (result != null && result is TournamentModel)
                        _addOrUpdateTournament(result);
                    },
                    color: isDark ? Colors.white12 : Colors.black12,
                    icon: Icons.edit_note_rounded,
                    label: "Ozgar",
                    textColor: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                TouchableButton(
                  onPressed: () => _confirmDelete(context, t),
                  color: Colors.redAccent.withOpacity(0.15),
                  icon: Icons.delete_outline_rounded,
                  label: "",
                  textColor: Colors.redAccent,
                  isIconOnly: true,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blueAccent),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class OnlineTournamentTab extends StatefulWidget {
  const OnlineTournamentTab({super.key});

  @override
  State<OnlineTournamentTab> createState() => _OnlineTournamentTabState();
}

class _OnlineTournamentTabState extends State<OnlineTournamentTab> {
  final OnlineTournamentService _service = OnlineTournamentService();
  final AuthService _authService = AuthService();
  bool _isCreating = false;

  void _createOnlineTournament() async {
    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Tizimga kirmagansiz!")));
      return;
    }

    final nameController = TextEditingController();
    String type = 'League';
    bool includeCreator = true;
    bool isDoubleLegged = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Yangi Onlayn Turnir"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Yaratish narxi: 100 Coin",
                  style: TextStyle(
                      color: Colors.amber, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "Turnir nomi")),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: type,
                isExpanded: true,
                items: ['League', 'Knockout'].map((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => setDialogState(() => type = val!),
              ),
              if (type == 'League') ...[
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text("2-davrali (Uy-mehmon)",
                      style: TextStyle(fontSize: 14)),
                  value: isDoubleLegged,
                  onChanged: (val) =>
                      setDialogState(() => isDoubleLegged = val!),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text("O'zim ham qatnashaman",
                    style: TextStyle(fontSize: 14)),
                value: includeCreator,
                onChanged: (val) => setDialogState(() => includeCreator = val!),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Bekor qilish")),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yaratish")),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF06DF5D)),
                const SizedBox(height: 20),
                Text("Biroz kuting, turnir yaratilmoqda...",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 16)),
              ],
            ),
          ),
        ),
      );

      try {
        await _service.createTournament(
          name: nameController.text,
          type: type,
          includeCreator: includeCreator,
          isDoubleRound: isDoubleLegged,
        );
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Muvaffaqiyatli yaratildi!")));
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    if (_authService.currentUser == null) {
      return const Center(child: Text("Onlayn turnirlar uchun tizimga kiring"));
    }

    if (_isCreating) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _service.getMyTournaments(),
        builder: (context, snapshot) {
          final tours = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
            itemCount: tours.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _buildAddCard(isDark);
              final tour = tours[index - 1];
              return _buildOnlineTile(tour, isDark);
            },
          );
        },
      ),
    );
  }

  void _joinViaCode() async {
    final codeController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Turnirga qo'shilish"),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            hintText: "Turnir ID kodini kiriting",
            labelText: "Turnir ID",
            prefixIcon: Icon(Icons.numbers),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Bekor qilish")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Qo'shilish")),
        ],
      ),
    );

    if (result == true && codeController.text.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF06DF5D)),
                const SizedBox(height: 20),
                Text("Biroz kuting, turnirga qo'shilinmoqda...",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 16)),
              ],
            ),
          ),
        ),
      );

      try {
        await _service.joinTournament(codeController.text.trim());
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Muvaffaqiyatli qo'shildingiz!")));
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(e.toString()), backgroundColor: Colors.red));
        }
      }
    }
  }

  Widget _buildAddCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _createOnlineTournament,
              child: GlassContainer(
                borderRadius: 20,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded,
                        color: Colors.blueAccent, size: 32),
                    const SizedBox(height: 8),
                    Text("Yangi Turnir",
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("100 Coin",
                        style: GoogleFonts.outfit(
                            fontSize: 11, color: Colors.amber)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _joinViaCode,
              child: GlassContainer(
                borderRadius: 20,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.login_rounded,
                        color: Color(0xFF06DF5D), size: 32),
                    const SizedBox(height: 8),
                    Text("ID bilan kirish",
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("Bepul",
                        style: GoogleFonts.outfit(
                            fontSize: 11, color: Colors.white54)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineTile(Map<String, dynamic> tour, bool isDark) {
    // Determine data
    final isCreator = tour['creatorId'] == _authService.currentUser?.uid;
    final modelMap = Map<String, dynamic>.from(tour['tournamentData']);
    final model = TournamentModel.fromJson(modelMap);

    // Status logic
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (model.isCompleted) {
      statusText = "Tugallangan";
      statusColor = Colors.blueAccent;
      statusIcon = Icons.emoji_events_rounded;
    } else if (model.isDrawDone) {
      statusText = "Jarayonda";
      statusColor = const Color(0xFF06DF5D);
      statusIcon = Icons.play_arrow_rounded;
    } else {
      statusText = "Kutilmoqda";
      statusColor = Colors.orangeAccent;
      statusIcon = Icons.hourglass_top_rounded;
    }

    // Dates
    // Provide a fallback if startDate is null (e.g. use current time or hide)
    final startDateStr = model.startDate != null
        ? "${model.startDate!.day}.${model.startDate!.month}.${model.startDate!.year}"
        : "";
    final endDateStr = model.endDate != null
        ? "${model.endDate!.day}.${model.endDate!.month}.${model.endDate!.year}"
        : "";

    return FutureBuilder<bool>(
      future: _service.isAdmin(),
      builder: (context, adminSnapshot) {
        final isAdmin = adminSnapshot.data ?? false;
        final hasControl = isCreator || isAdmin;

        return GestureDetector(
          onTap: () {
            if (model.isDrawDone) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TournamentBracketPage(
                    tournament: model,
                    isOnline: true,
                    hasControl: hasControl,
                    onUpdate: (updatedModel) {
                      _service.updateTournamentData(tour['id'], updatedModel);
                    },
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OnlineTournamentLobbyPage(tournament: tour),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  // HEADER: Name & Status Icon
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tour['name'],
                                  style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.people_outline_rounded,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text("${model.teams.length} ishtirokchi",
                                      style: GoogleFonts.outfit(
                                          fontSize: 13, color: Colors.grey)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.category_outlined,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(model.typeString,
                                      style: GoogleFonts.outfit(
                                          fontSize: 13, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (hasControl)
                          Material(
                            color: Colors.transparent,
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.redAccent),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _confirmDeleteOnline(
                                  tour['id'], tour['name']),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // DIVIDER
                  Divider(
                      height: 1,
                      color: (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.05)),

                  // FOOTER: Dates & Action Text
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.02),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24)),
                    ),
                    child: Row(
                      children: [
                        // Dates
                        if (startDateStr.isNotEmpty)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Boshlandi:",
                                    style: GoogleFonts.outfit(
                                        fontSize: 10, color: Colors.grey)),
                                Text(startDateStr,
                                    style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        if (endDateStr.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Tugadi:",
                                    style: GoogleFonts.outfit(
                                        fontSize: 10, color: Colors.grey)),
                                Text(endDateStr,
                                    style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],

                        // Action Button (Simulated)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            statusText,
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                                fontSize: 13),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteOnline(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Onlayn turnirni o'chirish"),
        content: Text("$name turnirini o'chirmoqchimisiz?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Yo'q")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirm
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                            color: Colors.redAccent),
                        const SizedBox(height: 20),
                        Text("Biroz kuting, turnir o'chirilmoqda...",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              );

              try {
                await _service.deleteTournament(id);
                if (mounted) Navigator.pop(context); // Close loading
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text("Ha", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ArchiveTournamentTab extends StatefulWidget {
  const ArchiveTournamentTab({super.key});

  @override
  State<ArchiveTournamentTab> createState() => _ArchiveTournamentTabState();
}

class _ArchiveTournamentTabState extends State<ArchiveTournamentTab> {
  List<TournamentModel> _archived = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArchived();
  }

  Future<void> _loadArchived() async {
    final prefs = await SharedPreferences.getInstance();
    final String? archivedString = prefs.getString('archived_tournaments');

    if (archivedString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(archivedString);
        setState(() {
          _archived = jsonList
              .map((json) =>
                  TournamentModel.fromJson(json as Map<String, dynamic>))
              .toList();
        });
      } catch (e) {
        _archived = [];
      }
    }
    setState(() => _isLoading = false);
  }

  void _confirmDelete(BuildContext context, TournamentModel tournament) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Arxivdan o'chirish"),
        content: Text("${tournament.name}ni butunlay o'chirasizmi?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Yo'q")),
          TextButton(
              onPressed: () async {
                setState(() {
                  _archived.removeWhere((t) => t.id == tournament.id);
                });
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('archived_tournaments',
                    jsonEncode(_archived.map((e) => e.toJson()).toList()));
                Navigator.pop(context);
              },
              child: const Text("Ha", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    if (_archived.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.archive_outlined,
                size: 64, color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(height: 16),
            Text("Arxivlar mavjud emas",
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.white38 : Colors.black38)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadArchived,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
        itemCount: _archived.length,
        itemBuilder: (context, index) {
          final t = _archived[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t.name,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF06DF5D),
                          )),
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.blue, size: 28),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: isDark ? Colors.white10 : Colors.black12),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildChip("${t.teams.length} jamoa",
                          Icons.people_outline, isDark),
                      const SizedBox(width: 10),
                      _buildChip(t.typeString, Icons.grid_view_rounded, isDark),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Holati: Tugallangan (Arxiv)",
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TouchableButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => TournamentBracketPage(
                                        tournament: t, hasControl: false)));
                          },
                          color: const Color(0xFF1E3A5F),
                          icon: Icons.visibility_outlined,
                          label: "Ko'rish",
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TouchableButton(
                        onPressed: () => _confirmDelete(context, t),
                        color: Colors.redAccent.withOpacity(0.15),
                        icon: Icons.delete_outline_rounded,
                        label: "",
                        textColor: Colors.redAccent,
                        isIconOnly: true,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.white60 : Colors.black54),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87)),
        ],
      ),
    );
  }
}

class TouchableButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  final IconData icon;
  final String label;
  final Color textColor;
  final bool isIconOnly;

  const TouchableButton({
    super.key,
    required this.onPressed,
    required this.color,
    required this.icon,
    required this.label,
    required this.textColor,
    this.isIconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: isIconOnly ? 0 : 12),
        width: isIconOnly ? 44 : null,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: textColor),
            if (!isIconOnly) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
