import 'package:efinfo_beta/additional/colors.dart';
import 'package:efinfo_beta/tournament/team_model.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class TournamentEditorPage extends StatefulWidget {
  final TournamentModel? tournament;

  const TournamentEditorPage({super.key, this.tournament});

  @override
  State<TournamentEditorPage> createState() => _TournamentEditorPageState();
}

class _TournamentEditorPageState extends State<TournamentEditorPage> {
  final TextEditingController _teamController = TextEditingController();
  final TextEditingController _tournamentNameController =
      TextEditingController();
  late List<TeamModel> _teams;
  late bool _isDrawLocked; // Qura tashlangan bo'lsa, tahrirlash cheklanadi
  late TournamentType _selectedType;
  late bool _isDoubleRound;

  @override
  void initState() {
    super.initState();
    if (widget.tournament != null) {
      _tournamentNameController.text = widget.tournament!.name;
      _teams = List.from(widget.tournament!.teams
          .map((t) => TeamModel(name: t.name, color: t.color, id: t.id)));
      _isDrawLocked = widget.tournament!.isDrawDone;
      _selectedType = widget.tournament!.type;
      _isDoubleRound =
          widget.tournament!.leagueSettings?.isDoubleRound ?? false;
    } else {
      _teams = [];
      _isDrawLocked = false;
      _selectedType = TournamentType.knockout;
      _isDoubleRound = false;
    }
  }

  void _addTeam() {
    String name = _teamController.text.trim();
    if (name.isNotEmpty) {
      if (_teams.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
        _showSnackbar("Bu jamoa allaqachon mavjud!", Colors.orange);
        return;
      }
      setState(() {
        _teams.add(TeamModel(name: name));
        _teamController.clear();
      });
    }
  }

  void _removeTeam(TeamModel team) {
    if (_isDrawLocked) return;
    setState(() {
      _teams.remove(team);
    });
  }

  void _saveTournament() {
    String name = _tournamentNameController.text.trim();
    if (name.isEmpty) {
      _showSnackbar("Turnir nomini kiriting!", Colors.orange);
      return;
    }

    int teamCount = _teams.length;

    if (teamCount < 2) {
      _showSnackbar("Kamida 2 ta jamoa bo'lishi kerak!", Colors.orange);
      return;
    }

    if (_selectedType == TournamentType.knockout) {
      // 2, 4, 8, 16, 32... tekshiruvi
      if (teamCount % 2 != 0 || (teamCount & (teamCount - 1)) != 0) {
        _showSnackbar(
          "Knockout turniri uchun jamoalar soni 2 ning darajasi bo'lishi shart (2, 4, 8, 16, 32).",
          Colors.orange,
        );
        return;
      }
    }

    TournamentModel result;
    if (widget.tournament != null) {
      result = TournamentModel(
        name: name,
        teams: _teams,
        id: widget.tournament!.id,
        isDrawDone: widget.tournament!.isDrawDone,
        matches: widget.tournament!.matches,
        championId: widget.tournament!.championId,
        type: _selectedType,
        leagueSettings: _selectedType == TournamentType.league
            ? LeagueSettings(isDoubleRound: _isDoubleRound)
            : null,
      );
    } else {
      result = TournamentModel(
        name: name,
        teams: _teams,
        type: _selectedType,
        leagueSettings: _selectedType == TournamentType.league
            ? LeagueSettings(isDoubleRound: _isDoubleRound)
            : null,
      );
    }

    Navigator.pop(context, result);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        title: Text(widget.tournament == null
            ? "Yangi Turnir Tuzish"
            : "Turnirni Tahrirlash"),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Turnir Nomi
            TextField(
              controller: _tournamentNameController,
              decoration: const InputDecoration(
                labelText: 'Turnir Nomi',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Turnir Turi
            if (!_isDrawLocked) ...[
              const Text(
                "Turnir Formatini Tanlang:",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeCard(
                      TournamentType.knockout,
                      "Knockout",
                      BoxIcons.bx_bracket,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTypeCard(
                      TournamentType.league,
                      "League (LaLiga)",
                      BoxIcons.bx_table,
                    ),
                  ),
                ],
              ),
              if (_selectedType == TournamentType.league) ...[
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: const Text("Uy-Mehmon o'yinlari (2 davra)",
                      style: TextStyle(color: Colors.white)),
                  value: _isDoubleRound,
                  onChanged: (val) {
                    setState(() {
                      _isDoubleRound = val ?? false;
                    });
                  },
                  activeColor: Colors.blue,
                  checkColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              const SizedBox(height: 20),
            ],

            // Jamoa Qo'shish
            if (!_isDrawLocked)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _teamController,
                      decoration: const InputDecoration(
                        labelText: 'Qatnashchi nomini kiriting',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _addTeam(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _addTeam,
                    mini: true,
                    backgroundColor: Colors.green,
                    child: const Icon(BoxIcons.bx_plus, color: Colors.white),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: const Text(
                  "Qura tashlangan. Jamoalar ro'yxatini va turini o'zgartirish mumkin emas.",
                  style: TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 15),

            Text(
              'Qatnashchilar: ${_teams.length} ta jamoa',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            const Divider(color: Colors.grey),

            // Jamoalar Ro'yxati
            Expanded(
              child: ListView.builder(
                itemCount: _teams.length,
                itemBuilder: (context, index) {
                  return _buildTeamListItem(_teams[index]);
                },
              ),
            ),

            // Saqlash Tugmasi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveTournament,
                icon: const Icon(BoxIcons.bx_save, color: Colors.white),
                label: const Text(
                  "Saqlash",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(TournamentType type, String title, IconData icon) {
    bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamListItem(TeamModel team) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          width: 5,
          height: 40,
          decoration: BoxDecoration(
            color: team.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        title: Text(team.name, style: const TextStyle(color: Colors.white)),
        trailing: !_isDrawLocked
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.redAccent),
                onPressed: () => _removeTeam(team),
              )
            : const Icon(Icons.lock, color: Colors.grey),
      ),
    );
  }
}
