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

  @override
  void initState() {
    super.initState();
    if (widget.tournament != null) {
      _tournamentNameController.text = widget.tournament!.name;
      // Listni nusxalash (widgetni emas)
      _teams = List.from(widget.tournament!.teams
          .map((t) => TeamModel(name: t.name, color: t.color, id: t.id)));
      _isDrawLocked = widget.tournament!.isDrawDone;
    } else {
      _teams = [];
      _isDrawLocked = false;
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
        _teams
            .add(TeamModel(name: name)); // TeamModel endi avtomatik rang oladi
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

    // 2, 4, 8, 12, 16, 20, ... tekshiruvi
    if (teamCount % 2 != 0 || (teamCount & (teamCount - 1)) != 0) {
      _showSnackbar(
        "Jamoalar soni juft va uning 4 ga bo‘linadigan bo‘lishi shart. Masalan: 2, 4, 8, 12, 16.",
        Colors.orange,
      );
      return;
    }

    // Saqlashdan oldin yangilangan modelni qaytarish
    TournamentModel result;
    if (widget.tournament != null) {
      result = TournamentModel(
        name: name,
        teams: _teams,
        id: widget.tournament!.id,
        isDrawDone: widget.tournament!.isDrawDone,
        matches: widget.tournament!.matches,
        championId: widget.tournament!.championId,
      );
    } else {
      result = TournamentModel(
        name: name,
        teams: _teams,
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
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Jamoa Qo'shish
            if (!_isDrawLocked)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _teamController,
                      decoration: const InputDecoration(
                        labelText: 'Qatnashchi nomini kiriting',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) =>
                          _addTeam(), // Enter bosilganda qo'shish
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
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: const Text(
                  "Qura tashlangan. Jamoalar ro'yxatini o'zgartirish mumkin emas.",
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 15),

            Text(
              'Qatnashchilar: ${_teams.length} ta jamoa',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const Divider(),

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
                icon: const Icon(BoxIcons.bx_save, color: Colors.black),
                label: const Text(
                  "Saqlash",
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamListItem(TeamModel team) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 5,
          height: 40,
          decoration: BoxDecoration(
            color: team.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        title: Text(team.name),
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
