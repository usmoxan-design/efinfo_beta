import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:efinfo_beta/tournament/team_model.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

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
  late bool _isAutoSchedule;
  late int _daysInterval;
  late int _startHour;
  late int _endHour;

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
      _isAutoSchedule =
          widget.tournament!.leagueSettings?.isAutoSchedule ?? false;
      _daysInterval = widget.tournament!.leagueSettings?.daysInterval ?? 1;
      _startHour = widget.tournament!.leagueSettings?.startHour ?? 18;
      _endHour = widget.tournament!.leagueSettings?.endHour ?? 22;
    } else {
      _teams = [];
      _isDrawLocked = false;
      _selectedType = TournamentType.knockout;
      _isDoubleRound = false;
      _isAutoSchedule = false;
      _daysInterval = 1;
      _startHour = 18;
      _endHour = 22;
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
            ? LeagueSettings(
                isDoubleRound: _isDoubleRound,
                isAutoSchedule: _isAutoSchedule,
                daysInterval: _daysInterval,
                startHour: _startHour,
                endHour: _endHour,
              )
            : null,
      );
    } else {
      result = TournamentModel(
        name: name,
        teams: _teams,
        type: _selectedType,
        leagueSettings: _selectedType == TournamentType.league
            ? LeagueSettings(
                isDoubleRound: _isDoubleRound,
                isAutoSchedule: _isAutoSchedule,
                daysInterval: _daysInterval,
                startHour: _startHour,
                endHour: _endHour,
              )
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.tournament == null
              ? "Yangi Turnir Tuzish"
              : "Turnirni Tahrirlash",
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Turnir Nomi
              TextField(
                controller: _tournamentNameController,
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Turnir Nomi',
                  labelStyle: GoogleFonts.outfit(
                      color: isDark ? Colors.white54 : Colors.black54),
                  hintText: "Turnir nomini kiriting...",
                  hintStyle: GoogleFonts.outfit(
                      color: isDark ? Colors.white24 : Colors.black26),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: isDark ? Colors.white10 : Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF06DF5D)),
                  ),
                  filled: true,
                  fillColor:
                      (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                ),
              ),
              const SizedBox(height: 20),

              // Turnir Turi
              if (!_isDrawLocked) ...[
                Text(
                  "Turnir Formatini Tanlang:",
                  style: GoogleFonts.outfit(
                      color: isDark ? Colors.white : Colors.black,
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
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTypeCard(
                        TournamentType.league,
                        "League (LaLiga)",
                        BoxIcons.bx_table,
                        isDark,
                      ),
                    ),
                  ],
                ),
                if (_selectedType == TournamentType.league) ...[
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: Text("Uy-Mehmon o'yinlari (2 davra)",
                        style: GoogleFonts.outfit(
                            color: isDark ? Colors.white70 : Colors.black87)),
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
                  CheckboxListTile(
                    title: Text("O'yin vaqtini avtomatik belgilash",
                        style: GoogleFonts.outfit(
                            color: isDark ? Colors.white70 : Colors.black87)),
                    value: _isAutoSchedule,
                    onChanged: (val) {
                      setState(() {
                        _isAutoSchedule = val ?? false;
                      });
                    },
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_isAutoSchedule) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Sozlamalar:",
                          style: GoogleFonts.outfit(
                              color: const Color(0xFF06DF5D),
                              fontWeight: FontWeight.bold)),
                    ),
                    _buildSliderSetting(
                      "Kunlar oralig'i (interval)",
                      _daysInterval.toDouble(),
                      1,
                      7,
                      (val) => setState(() => _daysInterval = val.toInt()),
                      "$_daysInterval kun",
                    ),
                    _buildSliderSetting(
                      "O'yinlar boshlanish soati",
                      _startHour.toDouble(),
                      0,
                      23,
                      (val) => setState(() => _startHour = val.toInt()),
                      "$_startHour:00 dan",
                    ),
                    _buildSliderSetting(
                      "O'yinlar tugash soati",
                      _endHour.toDouble(),
                      0,
                      23,
                      (val) => setState(() {
                        _endHour = val.toInt();
                        if (_endHour < _startHour) _startHour = _endHour;
                      }),
                      "$_endHour:00 gacha",
                    ),
                  ],
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
                        style: GoogleFonts.outfit(
                            color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Qatnashchi nomini kiriting',
                          labelStyle: GoogleFonts.outfit(
                              color: isDark ? Colors.white54 : Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color:
                                    isDark ? Colors.white10 : Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                const BorderSide(color: Color(0xFF06DF5D)),
                          ),
                          filled: true,
                          fillColor: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.05),
                        ),
                        onSubmitted: (_) => _addTeam(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: _addTeam,
                      mini: true,
                      backgroundColor: const Color(0xFF06DF5D),
                      elevation: 0,
                      child: const Icon(BoxIcons.bx_plus, color: Colors.black),
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
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black),
              ),
              Divider(color: isDark ? Colors.white10 : Colors.black12),

              // Jamoalar Ro'yxati
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _teams.length,
                itemBuilder: (context, index) {
                  return _buildTeamListItem(_teams[index]);
                },
              ),

              const SizedBox(height: 20),

              // Saqlash Tugmasi
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveTournament,
                  icon: const Icon(BoxIcons.bx_save, color: Colors.black),
                  label: Text(
                    "Saqlash",
                    style: GoogleFonts.outfit(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06DF5D),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderSetting(String label, double value, double min, double max,
      Function(double) onChanged, String valueLabel) {
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 13)),
            Text(valueLabel,
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          onChanged: onChanged,
          activeColor: const Color(0xFF06DF5D),
          inactiveColor:
              (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildTypeCard(
      TournamentType type, String title, IconData icon, bool isDark) {
    bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        borderRadius: 12,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF06DF5D).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF06DF5D)
                  : (isDark ? Colors.white10 : Colors.black12),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected
                      ? const Color(0xFF06DF5D)
                      : (isDark ? Colors.white38 : Colors.black38),
                  size: 30),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? Colors.white38 : Colors.black38),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamListItem(TeamModel team) {
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: GlassContainer(
        borderRadius: 12,
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Container(
            width: 5,
            height: 40,
            decoration: BoxDecoration(
              color: team.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          title: Text(team.name,
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600)),
          trailing: !_isDrawLocked
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  onPressed: () => _removeTeam(team),
                )
              : Icon(Icons.lock,
                  color: isDark ? Colors.white24 : Colors.black26),
        ),
      ),
    );
  }
}
