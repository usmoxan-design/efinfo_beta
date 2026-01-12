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
    _tabController = TabController(length: 2, vsync: this);
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
              Tab(text: "Oflayn"),
              Tab(text: "Onlayn"),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OfflineTournamentTab(),
          OnlineTournamentTab(),
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

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _tournaments.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildAddCard(isDark);
        return _buildTile(_tournaments[index - 1], isDark);
      },
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.name,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF06DF5D))),
                IconButton(
                    onPressed: () => _confirmDelete(context, t),
                    icon:
                        const Icon(Icons.delete, color: Colors.red, size: 20)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                TournamentBracketPage(tournament: t)));
                    if (res != null && res is TournamentModel)
                      _addOrUpdateTournament(res);
                  },
                  child: const Text("Ko'rish"),
                ),
              ],
            )
          ],
        ),
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
      setState(() => _isCreating = true);
      try {
        await _service.createTournament(
          name: nameController.text,
          type: type,
          includeCreator: includeCreator,
        );
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Muvaffaqiyatli yaratildi!")));
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) setState(() => _isCreating = false);
      }
    }
  }

  void _invitePlayer(String tourId, String tourName) async {
    final emailController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("O'yinchi taklif qilish"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
              hintText: "example@efhub.uz", labelText: "Foydalanuvchi emaili"),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Bekor qilish")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Taklif qilish")),
        ],
      ),
    );

    if (result == true && emailController.text.isNotEmpty) {
      try {
        await _service.sendJoinRequest(
            tourId, tourName, emailController.text.trim());
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Taklif yuborildi!")));
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
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

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _service.getMyTournaments(),
      builder: (context, snapshot) {
        final tours = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: tours.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _buildAddCard(isDark);
            final tour = tours[index - 1];
            return _buildOnlineTile(tour, isDark);
          },
        );
      },
    );
  }

  Widget _buildAddCard(bool isDark) {
    return GestureDetector(
      onTap: _createOnlineTournament,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.add_rounded, color: Colors.blueAccent, size: 32),
              const SizedBox(height: 8),
              Text("Yangi Onlayn Turnir",
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Narxi: 100 Coin",
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.amber)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineTile(Map<String, dynamic> tour, bool isDark) {
    final isCreator = tour['creatorId'] == _authService.currentUser?.uid;
    final List players = tour['players'] ?? [];

    return FutureBuilder<bool>(
      future: _service.isAdmin(),
      builder: (context, adminSnapshot) {
        final isAdmin = adminSnapshot.data ?? false;
        final hasControl = isCreator || isAdmin;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tour['name'],
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            fontSize: 18)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(tour['type'],
                          style: GoogleFonts.outfit(
                              fontSize: 12, color: Colors.blueAccent)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("O'yinchilar: ${players.length}",
                    style:
                        GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                const Divider(height: 24),
                Row(
                  children: [
                    if (hasControl &&
                        !TournamentModel.fromJson(Map<String, dynamic>.from(
                                tour['tournamentData']))
                            .isDrawDone)
                      ElevatedButton.icon(
                        onPressed: () =>
                            _invitePlayer(tour['id'], tour['name']),
                        icon: const Icon(Icons.person_add_rounded, size: 16),
                        label: const Text("Taklif"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        final modelMap =
                            Map<String, dynamic>.from(tour['tournamentData']);
                        final model = TournamentModel.fromJson(modelMap);

                        if (model.isDrawDone) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TournamentBracketPage(
                                tournament: model,
                                isOnline: true,
                                hasControl: hasControl,
                                onUpdate: (updatedModel) {
                                  _service.updateTournamentData(
                                      tour['id'], updatedModel);
                                },
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OnlineTournamentLobbyPage(tournament: tour),
                            ),
                          );
                        }
                      },
                      child: const Text("Ko'rish"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
