import 'package:efinfo_beta/services/online_tournament_service.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/tournament/tournamentBracket.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OnlineTournamentLobbyPage extends StatefulWidget {
  final Map<String, dynamic> tournament;
  const OnlineTournamentLobbyPage({super.key, required this.tournament});

  @override
  State<OnlineTournamentLobbyPage> createState() =>
      _OnlineTournamentLobbyPageState();
}

class _OnlineTournamentLobbyPageState extends State<OnlineTournamentLobbyPage> {
  final OnlineTournamentService _service = OnlineTournamentService();
  late String _tournamentId;

  @override
  void initState() {
    super.initState();
    _tournamentId = widget.tournament['id'];
  }

  void _renameTournament() async {
    final controller = TextEditingController(text: widget.tournament['name']);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Turnirni qayta nomlash"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Yangi nom"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Bekor qilish")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Saqlash")),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty) {
      await _service.renameTournament(_tournamentId, controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return StreamBuilder<Map<String, dynamic>>(
      stream: _service.getTournament(_tournamentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        final tour = snapshot.data!;
        if (tour.isEmpty)
          return const Scaffold(body: Center(child: Text("Turnir topilmadi")));

        final List players = tour['players'] ?? [];
        final model = TournamentModel.fromJson(
            Map<String, dynamic>.from(tour['tournamentData']));
        final isDrawDone = model.isDrawDone;
        final isCreator = tour['creatorId'] == _service.currentUser?.uid;

        return FutureBuilder<bool>(
          future: _service.isAdmin(),
          builder: (context, adminSnapshot) {
            final isAdmin = adminSnapshot.data ?? false;
            final hasControl = isCreator || isAdmin;

            return Scaffold(
              backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
              appBar: AppBar(
                title: Text(tour['name'],
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  if (hasControl)
                    IconButton(
                        onPressed: _renameTournament,
                        icon: const Icon(Icons.edit_rounded,
                            color: Color(0xFF06DF5D))),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatsCard(players.length, isDark),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF06DF5D), size: 20),
                      const SizedBox(width: 8),
                      Text("Qo'shilganlar",
                          style: GoogleFonts.outfit(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...model.teams.map((team) {
                    return _buildPlayerTile(
                        team.name, team.id, true, isDark, hasControl);
                  }),
                  if (!isDrawDone) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.pending_rounded,
                            color: Colors.orangeAccent, size: 20),
                        const SizedBox(width: 8),
                        Text("Taklif qilinganlar",
                            style: GoogleFonts.outfit(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _service.getTournamentRequests(_tournamentId),
                      builder: (context, reqSnapshot) {
                        final requests = reqSnapshot.data
                                ?.where((r) => r['status'] == 'pending')
                                .toList() ??
                            [];
                        if (requests.isEmpty)
                          return Padding(
                            padding: const EdgeInsets.only(left: 28),
                            child: Text("Hozircha kutilayotganlar yo'q",
                                style: GoogleFonts.outfit(
                                    color: Colors.grey, fontSize: 14)),
                          );
                        return Column(
                          children: requests
                              .map((req) => _buildPlayerTile(req['toEmail'],
                                  req['toEmail'], false, isDark, hasControl))
                              .toList(),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TournamentBracketPage(
                          tournament: model,
                          isOnline: true,
                          hasControl: hasControl,
                          onUpdate: (updatedModel) {
                            _service.updateTournamentData(
                                _tournamentId, updatedModel);
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06DF5D),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                      isDrawDone
                          ? "Turnirni Ko'rish"
                          : (hasControl ? "Qura tashlash" : "Kutilmoqda..."),
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsCard(int count, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Jami qo'shilganlar",
                  style: GoogleFonts.outfit(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 14)),
              const SizedBox(height: 4),
              Text("$count ta ishtirokchi",
                  style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF06DF5D))),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF06DF5D).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group_rounded,
                color: Color(0xFF06DF5D), size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerTile(
      String name, String id, bool isJoined, bool isDark, bool isCreator) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 20,
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isJoined
                  ? const Color(0xFF06DF5D).withOpacity(0.2)
                  : Colors.amber.withOpacity(0.2),
              child: Icon(
                  isJoined ? Icons.person_rounded : Icons.mail_outline_rounded,
                  color: isJoined ? const Color(0xFF06DF5D) : Colors.amber,
                  size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w500, fontSize: 15)),
            ),
            if (isJoined && isCreator)
              IconButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Foydalanuvchini o'chirish"),
                      content: Text("$name ni turnirdan o'chirasizmi?"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Yo'q")),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Ha",
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _service.removePlayer(_tournamentId, id);
                  }
                },
                icon: const Icon(Icons.remove_circle_outline_rounded,
                    color: Colors.redAccent, size: 22),
              )
            else if (!isJoined)
              Text("Kutilmoqda",
                  style: GoogleFonts.outfit(
                      color: Colors.grey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
