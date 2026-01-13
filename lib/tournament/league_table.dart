import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:efinfo_beta/tournament/match_model.dart';
import 'package:efinfo_beta/tournament/service/league_service.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:efinfo_beta/tournament/team_stats_page.dart';
import 'package:efinfo_beta/tournament/tournament_charts_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LeagueTableWidget extends StatefulWidget {
  final TournamentModel tournament;
  final Function(MatchModel)? onMatchTap;

  const LeagueTableWidget({
    super.key,
    required this.tournament,
    this.onMatchTap,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    List<LeagueStats> standings =
        _leagueService.calculateStandings(widget.tournament, mode: _currentTab);

    return Column(
      children: [
        // Tabs (All, Home, Away)
        _buildTabs(isDark),
        const SizedBox(height: 16),

        // Standings Table
        _buildStandingsTable(standings, isDark),

        const SizedBox(height: 24),

        // Round Selector and Matches
        _buildRoundMatches(isDark),
      ],
    );
  }

  Widget _buildTabs(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _buildTabButton('all', 'Barchasi', isDark),
                    _buildTabButton('home', 'Uyda', isDark),
                    _buildTabButton('away', 'Mehmon', isDark),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildChartButton(isDark),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.visibility_outlined,
                  size: 14, color: isDark ? Colors.white54 : Colors.black54),
              const SizedBox(width: 8),
              Text("Ko'rinish:",
                  style: GoogleFonts.outfit(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              _buildModeButton('min', 'Kichik', isDark),
              const SizedBox(width: 6),
              _buildModeButton('max', 'To\'liq', isDark),
              const SizedBox(width: 6),
              _buildModeButton('form', 'Forma', isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LeagueTournamentChartsPage(tournament: widget.tournament),
          ),
        );
      },
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF06DF5D), const Color(0xFF00AA44)]
                : [const Color(0xFF06DF5D), const Color(0xFF05C050)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06DF5D).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child:
            const Icon(Icons.bar_chart_rounded, color: Colors.black, size: 24),
      ),
    );
  }

  Widget _buildModeButton(String mode, String label, bool isDark) {
    bool isSelected = _tableMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _tableMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF06DF5D).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF06DF5D).withOpacity(0.5)
                  : Colors.transparent),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected
                ? (isDark ? const Color(0xFF06DF5D) : Colors.black)
                : (isDark ? Colors.white30 : Colors.black26),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String tab, String label, bool isDark) {
    bool isSelected = _currentTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white10 : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: isSelected
                  ? (isDark ? const Color(0xFF06DF5D) : Colors.black)
                  : (isDark ? Colors.white38 : Colors.black38),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandingsTable(List<LeagueStats> standings, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text("Jadval",
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        GlassContainer(
          borderRadius: 16,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color:
                      (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    _buildHeaderCell("#", 25, isDark),
                    Expanded(
                        child: _buildHeaderCell("Jamoa", 0, isDark,
                            textAlign: TextAlign.start)),
                    if (_tableMode == 'max') ...[
                      _buildHeaderCell("O'", 30, isDark),
                      _buildHeaderCell("G'", 30, isDark),
                      _buildHeaderCell("D", 30, isDark),
                      _buildHeaderCell("M", 30, isDark),
                      _buildHeaderCell("Gollar", 50, isDark),
                    ] else if (_tableMode == 'min') ...[
                      _buildHeaderCell("O'", 30, isDark),
                      _buildHeaderCell("+/-", 40, isDark),
                    ] else if (_tableMode == 'form') ...[
                      _buildHeaderCell("Oxirgi 6 o'yin", 120, isDark),
                    ],
                    _buildHeaderCell("OCH", 35, isDark),
                  ],
                ),
              ),
              Divider(
                  height: 1, color: isDark ? Colors.white10 : Colors.black12),
              // Rows
              ...standings.asMap().entries.map((entry) {
                int index = entry.key;
                LeagueStats stats = entry.value;

                bool isMe = false;
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  if (stats.team.id == "creator_${user.uid}" ||
                      stats.team.id == user.email) {
                    isMe = true;
                  }
                }

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
                    color: isMe
                        ? Colors.blue.withOpacity(0.15)
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
                                      ? const Color(0xFF06DF5D)
                                      : Colors.blueAccent,
                                  child: Text("${index + 1}",
                                      style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                )
                              : Text("${index + 1}",
                                  style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stats.team.name,
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_tableMode == 'max') ...[
                          _buildDataCell("${stats.played}", 30, isDark),
                          _buildDataCell("${stats.won}", 30, isDark,
                              color: const Color(0xFF06DF5D)),
                          _buildDataCell("${stats.drawn}", 30, isDark),
                          _buildDataCell("${stats.lost}", 30, isDark,
                              color: Colors.redAccent),
                          _buildDataCell(
                              "${stats.goalsFor}:${stats.goalsAgainst}",
                              50,
                              isDark,
                              fontSize: 12),
                        ] else if (_tableMode == 'min') ...[
                          _buildDataCell("${stats.played}", 30, isDark),
                          _buildDataCell(
                              "${stats.goalDifference > 0 ? '+' : ''}${stats.goalDifference}",
                              40,
                              isDark,
                              color: stats.goalDifference >= 0
                                  ? const Color(0xFF06DF5D)
                                  : Colors.redAccent),
                        ] else if (_tableMode == 'form') ...[
                          _buildFormCell(stats.team.id, 120),
                        ],
                        _buildDataCell("${stats.points}", 35, isDark,
                            isBold: true,
                            color: isDark ? Colors.white : Colors.black),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoSection(isDark),
      ],
    );
  }

  Widget _buildHeaderCell(String label, double width, bool isDark,
      {TextAlign textAlign = TextAlign.center}) {
    return SizedBox(
      width: width == 0 ? null : width,
      child: Text(label,
          textAlign: textAlign,
          style: GoogleFonts.outfit(
              color: isDark ? Colors.white38 : Colors.black38, fontSize: 11)),
    );
  }

  Widget _buildDataCell(String value, double width, bool isDark,
      {Color? color, bool isBold = false, double fontSize = 13}) {
    return SizedBox(
      width: width,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(
          color: color ?? (isDark ? Colors.white70 : Colors.black87),
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

  Widget _buildInfoSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("O'", "O'ynalgan o'yinlar soni", isDark),
          _buildInfoRow("G'", "G'alabalar soni", isDark),
          _buildInfoRow("D", "Duranglar soni", isDark),
          _buildInfoRow("M", "Mag'lubiyatlar soni", isDark),
          _buildInfoRow(
              "+/-", "To'plar farqi (Urilgan - O'tkazib yuborilgan)", isDark),
          _buildInfoRow("OCH",
              "To'plangan umumiy ochkolar (3 g'alaba, 1 durang)", isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String symbol, String desc, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35,
            child: Text(symbol,
                style: GoogleFonts.outfit(
                    color: const Color(0xFF06DF5D),
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
          Text("- ",
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.white38 : Colors.black38)),
          Expanded(
            child: Text(desc,
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundMatches(bool isDark) {
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
              icon: Icon(Icons.chevron_left,
                  color: isDark ? Colors.white : Colors.black),
              onPressed: _currentRound > 1
                  ? () => setState(() => _currentRound--)
                  : null,
            ),
            Text(
              "$_currentRound-Tur",
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right,
                  color: isDark ? Colors.white : Colors.black),
              onPressed: _currentRound < totalRounds
                  ? () => setState(() => _currentRound++)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...roundMatches.map((match) => _buildMatchTile(match, isDark)),
      ],
    );
  }

  Widget _buildMatchTile(MatchModel match, bool isDark) {
    return GestureDetector(
      onTap: widget.onMatchTap != null ? () => widget.onMatchTap!(match) : null,
      child: GlassContainer(
        borderRadius: 12,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (match.date != null) ...[
              Text(
                DateFormat('dd.MM.yy HH:mm').format(match.date!),
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 10),
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
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: match.isPlayed
                          ? const Color(0xFF06DF5D)
                          : (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      match.isPlayed
                          ? "${match.scoreA} : ${match.scoreB}"
                          : "vs",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: match.isPlayed
                            ? Colors.black
                            : (isDark ? Colors.white38 : Colors.black38),
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
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500),
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
