import 'package:efinfo_beta/services/online_tournament_service.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/tournament/tournamentBracket.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _invitePlayer() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("O'yinchi taklif qilish"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            hintText: "Email (masalan: user@efhub.uz)",
            labelText: "Foydalanuvchi emaili",
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Bekor qilish")),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty) return;
              Navigator.pop(context); // Close input

              // Loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                            color: Color(0xFF06DF5D)),
                        const SizedBox(height: 20),
                        Text("Biroz kuting, taklifnoma yuborilmoqda...",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              );

              try {
                await _service.sendJoinRequest(_tournamentId,
                    widget.tournament['name'], emailController.text.trim());
                if (mounted) Navigator.pop(context); // Close loading
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Taklifnoma yuborildi!")));
              } catch (e) {
                if (mounted) Navigator.pop(context); // Close loading
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Xatolik: $e"), backgroundColor: Colors.red));
              }
            },
            child: const Text("Yuborish"),
          ),
        ],
      ),
    );
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
        final currentUserId = _service.currentUser?.uid;
        final currentUserEmail = _service.currentUser?.email;
        final isCreator = tour['creatorId'] == currentUserId;

        // Check if I am joined
        final bool amIJoined = players.contains(currentUserEmail);

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
                  // Copy ID Action
                  IconButton(
                    onPressed: () {
                      _copyTournamentId(tour['id']);
                    },
                    tooltip: "ID nusxalash",
                    icon: const Icon(Icons.copy_rounded,
                        color: Colors.blueAccent),
                  ),

                  if (hasControl && !isDrawDone)
                    IconButton(
                        onPressed: _invitePlayer,
                        icon: const Icon(Icons.person_add_alt_1_rounded,
                            color: Color(0xFF06DF5D))),
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
                  _buildStatsCard(players.length, tour['id'], isDark),
                  const SizedBox(height: 24),

                  // Re-join button for creator
                  if (isCreator && !amIJoined && !isDrawDone) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text("Siz turnirdan chiqib ketgansiz.",
                              style: TextStyle(color: Colors.orange)),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () => _rejoinAsCreator(),
                            icon: const Icon(Icons.login_rounded),
                            label: const Text("Qayta qo'shilish"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

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
                    // Check if this team is the creator
                    // Creator ID format: "creator_<uid>" or simple email but for creator usually "creator_<uid>" if added initially
                    bool isCreatorTeam =
                        team.id == "creator_${tour['creatorId']}";
                    // If creator joined via email later, it might be just email.
                    // But we check if team.id starts with creator_ or equals creator email (if we knew it).
                    // For UI distinction, checking ID format is safest for "Creator Team".

                    return _buildPlayerTile(team.name, team.id, true, isDark,
                        hasControl, isCreatorTeam);
                  }),
                  if (!isDrawDone) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.pending_rounded,
                            color: Colors.orangeAccent, size: 20),
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
                        // ... existing logic
                        return Column(
                          children: requests
                              .map((req) => _buildPlayerTile(
                                  req['toEmail'],
                                  req['toEmail'],
                                  false,
                                  isDark,
                                  hasControl,
                                  false))
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
                    // Start/View logic
                    if (isDrawDone || hasControl) {
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
                    }
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

  void _copyTournamentId(String id) {
    // Platform channel to copy
    // clipboard
    // Use Services

    Clipboard.setData(ClipboardData(text: id));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Turnir ID nusxalandi!")));
  }

  void _rejoinAsCreator() async {
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
              Text("Biroz kuting, qayta qo'shilinmoqda...",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 16)),
            ],
          ),
        ),
      ),
    );

    try {
      await _service.joinTournament(_tournamentId);
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Siz qayta qo'shildingiz!")));
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xatolik: $e"), backgroundColor: Colors.red));
    }
  }

  Widget _buildStatsCard(int count, String id, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(children: [
        Row(
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
        const SizedBox(height: 16),
        // ID Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black26 : Colors.black12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "ID: $id",
                  style: GoogleFonts.robotoMono(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () => _copyTournamentId(id),
                child: const Icon(Icons.copy, size: 16, color: Colors.blue),
              )
            ],
          ),
        )
      ]),
    );
  }

  Widget _buildPlayerTile(String name, String id, bool isJoined, bool isDark,
      bool hasControl, bool isCreatorPlayer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 20,
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isJoined
                      ? const Color(0xFF06DF5D).withOpacity(0.2)
                      : Colors.amber.withOpacity(0.2),
                  child: Icon(
                      isJoined
                          ? Icons.person_rounded
                          : Icons.mail_outline_rounded,
                      color: isJoined ? const Color(0xFF06DF5D) : Colors.amber,
                      size: 18),
                ),
                if (isCreatorPlayer)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 14),
                  )
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(name,
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500, fontSize: 15),
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (isCreatorPlayer) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded,
                        color: Colors.amber, size: 16),
                  ]
                ],
              ),
            ),
            if (isJoined &&
                hasControl &&
                !isCreatorPlayer) // Don't allow deleting creator team easily here
              IconButton(
                onPressed: () async {
                  // Delete logic (reuse existing)
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
                              Text("Biroz kuting, o'yinchi o'chirilmoqda...",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    );

                    try {
                      await _service.removePlayer(_tournamentId, id);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Xatolik: $e"),
                          backgroundColor: Colors.red));
                    }
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
