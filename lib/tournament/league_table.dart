import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/tournament/match_model.dart';
import 'package:efinfo_beta/tournament/service/league_service.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:efinfo_beta/tournament/team_stats_page.dart';
import 'package:efinfo_beta/tournament/tournament_charts_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeagueTableWidget extends StatefulWidget {
  final TournamentModel tournament;
  final Function(MatchModel) onMatchTap;

  const LeagueTableWidget({
    super.key,
    required this.tournament,
    required this.onMatchTap,
  });

  @override
  State<LeagueTableWidget> createState() => _LeagueTableWidgetState();
}

class _LeagueTableWidgetState extends State<LeagueTableWidget> {
  String _currentTab = 'all'; // all, home, away
  String _tableMode = 'min'; // min, max, form
  int _currentRound = 1;
  final LeagueService _leagueService = LeagueService();

  @override
  void initState() {
    super.initState();
    _currentRound = _calculateCurrentRound();
  }

  int _calculateCurrentRound() {
    for (int r = 1; r <= _getTotalRounds(); r++) {
      if (widget.tournament.matches
          .where((m) => m.round == r && !m.isPlayed)
          .isNotEmpty) {
        return r;
      }
    }
    return 1;
  }

  int _getTotalRounds() {
    if (widget.tournament.matches.isEmpty) return 0;
    return widget.tournament.matches
        .map((m) => m.round)
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    List<LeagueStats> standings =
        _leagueService.calculateStandings(widget.tournament, mode: _currentTab);

    return Column(
      children: [
        // Tabs (All, Home, Away)
        _buildTabs(),
        const SizedBox(height: 16),

        // Standings Table
        _buildStandingsTable(standings),

        const SizedBox(height: 24),

        // Round Selector and Matches
        _buildRoundMatches(),
      ],
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        Row(
          children: [
            _buildTabButton('all', 'Barchasi'),
            const SizedBox(width: 8),
            _buildTabButton('home', 'Uyda'),
            const SizedBox(width: 8),
            _buildTabButton('away', 'Mehmon'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeagueTournamentChartsPage(
                        tournament: widget.tournament),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.show_chart, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text("Statistika",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text("Ko'rinish:",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(width: 8),
            _buildModeButton('min', 'Kichik'),
            const SizedBox(width: 4),
            _buildModeButton('max', 'To\'liq'),
            const SizedBox(width: 4),
            _buildModeButton('form', 'Forma'),
          ],
        ),
      ],
    );
  }

  Widget _buildModeButton(String mode, String label) {
    bool isSelected = _tableMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _tableMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[800] : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String tab, String label) {
    bool isSelected = _currentTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStandingsTable(List<LeagueStats> standings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text("Jadval",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(
                        width: 25,
                        child: Text("#",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13))),
                    const Expanded(
                        child: Text("Jamoa",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13))),
                    if (_tableMode == 'max') ...[
                      _buildHeaderCell("O'", 30),
                      _buildHeaderCell("G'", 30),
                      _buildHeaderCell("D", 30),
                      _buildHeaderCell("M", 30),
                      _buildHeaderCell("Gollar", 50),
                    ] else if (_tableMode == 'min') ...[
                      _buildHeaderCell("O'", 30),
                      _buildHeaderCell("+/-", 40),
                    ] else if (_tableMode == 'form') ...[
                      _buildHeaderCell("Oxirgi 6 o'yin", 120),
                    ],
                    _buildHeaderCell("OCH", 35),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Rows
              ...standings.asMap().entries.map((entry) {
                int index = entry.key;
                LeagueStats stats = entry.value;
                bool isFirst = index == 0;
                bool isTop4 = index < 4;
                bool is5th = index == 4;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeagueTeamStatsPage(
                          tournament: widget.tournament,
                          teamId: stats.team.id,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    color: isFirst
                        ? Colors.green.withOpacity(0.15)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 25,
                          child: (isTop4 || is5th) && _tableMode != 'form'
                              ? CircleAvatar(
                                  radius: 10,
                                  backgroundColor: isTop4
                                      ? Colors.green[700]
                                      : Colors.blue[800],
                                  child: Text("${index + 1}",
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                )
                              : Text("${index + 1}",
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stats.team.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_tableMode == 'max') ...[
                          _buildDataCell("${stats.played}", 30),
                          _buildDataCell("${stats.won}", 30,
                              color: Colors.green[800]),
                          _buildDataCell("${stats.drawn}", 30),
                          _buildDataCell("${stats.lost}", 30,
                              color: Colors.red[800]),
                          _buildDataCell(
                              "${stats.goalsFor}:${stats.goalsAgainst}", 50,
                              fontSize: 12),
                        ] else if (_tableMode == 'min') ...[
                          _buildDataCell("${stats.played}", 30),
                          _buildDataCell(
                              "${stats.goalDifference > 0 ? '+' : ''}${stats.goalDifference}",
                              40,
                              color: stats.goalDifference >= 0
                                  ? Colors.blue[800]
                                  : Colors.red[800]),
                        ] else if (_tableMode == 'form') ...[
                          _buildFormCell(stats.team.id, 120),
                        ],
                        _buildDataCell("${stats.points}", 35,
                            isBold: true, color: Colors.black),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoSection(),
      ],
    );
  }

  Widget _buildHeaderCell(String label, double width) {
    return SizedBox(
      width: width,
      child: Text(label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 11)),
    );
  }

  Widget _buildDataCell(String value, double width,
      {Color? color, bool isBold = false, double fontSize = 13}) {
    return SizedBox(
      width: width,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color ?? Colors.black,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildFormCell(String teamId, double width) {
    final teamStats =
        _leagueService.getTeamDetailedStats(widget.tournament, teamId);
    final form = teamStats.form.reversed.take(6).toList().reversed.toList();

    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: form.map((res) {
          Color color = Colors.grey;
          if (res == 'W') color = Colors.green;
          if (res == 'D') color = Colors.orange;
          if (res == 'L') color = Colors.red;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                res,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("O'", "O'ynalgan o'yinlar soni"),
          _buildInfoRow("G'", "G'alabalar soni"),
          _buildInfoRow("D", "Duranglar soni"),
          _buildInfoRow("M", "Mag'lubiyatlar soni"),
          _buildInfoRow("+/-", "To'plar farqi (Urilgan - O'tkazib yuborilgan)"),
          _buildInfoRow(
              "OCH", "To'plangan umumiy ochkolar (3 g'alaba, 1 durang)"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String symbol, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35,
            child: Text(symbol,
                style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
          const Text("- ", style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(desc,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundMatches() {
    int totalRounds = _getTotalRounds();
    if (totalRounds == 0) return const SizedBox();

    List<MatchModel> roundMatches = widget.tournament.matches
        .where((m) => m.round == _currentRound)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: _currentRound > 1
                  ? () => setState(() => _currentRound--)
                  : null,
            ),
            Text(
              "$_currentRound-Tur",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              onPressed: _currentRound < totalRounds
                  ? () => setState(() => _currentRound++)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...roundMatches.map((match) => _buildMatchTile(match)).toList(),
      ],
    );
  }

  Widget _buildMatchTile(MatchModel match) {
    return GestureDetector(
      onTap: () => widget.onMatchTap(match),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            if (match.date != null) ...[
              Text(
                DateFormat('dd.MM.yy HH:mm').format(match.date!),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    match.teamA?.name ?? "TBD",
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: match.isPlayed
                          ? AppColors.accent
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      match.isPlayed
                          ? "${match.scoreA} : ${match.scoreB}"
                          : "vs",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: match.isPlayed ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    match.teamB?.name ?? "TBD",
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
