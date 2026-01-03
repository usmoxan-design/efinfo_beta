import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:efinfo_beta/tournament/match_model.dart';
import 'package:efinfo_beta/tournament/service/league_service.dart';
import 'package:efinfo_beta/tournament/team_model.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LeagueTeamStatsPage extends StatefulWidget {
  final TournamentModel tournament;
  final String teamId;

  const LeagueTeamStatsPage({
    super.key,
    required this.tournament,
    required this.teamId,
  });

  @override
  State<LeagueTeamStatsPage> createState() => _LeagueTeamStatsPageState();
}

class _LeagueTeamStatsPageState extends State<LeagueTeamStatsPage> {
  int _selectedTabIndex = 0; // 0: Details, 1: Matches, 2: Standings
  final LeagueService _leagueService = LeagueService();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final stats =
        _leagueService.getTeamDetailedStats(widget.tournament, widget.teamId);
    final standings = _leagueService.calculateStandings(widget.tournament);

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(stats.team.name,
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black)),
      ),
      body: Column(
        children: [
          // Header: Logo / Info (Cleaned as requested)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildTeamHeader(stats, isDark),
          ),

          // Tabs
          _buildInternalTabs(isDark),

          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildTabContent(stats, standings, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamHeader(TeamDetailedStats stats, bool isDark) {
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: stats.team.color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: stats.team.color, width: 2),
          ),
          child: Icon(Icons.shield, color: stats.team.color, size: 35),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stats.team.name,
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Text(
                  "League Participant",
                  style: GoogleFonts.outfit(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInternalTabs(bool isDark) {
    return Row(
      children: [
        _buildTab(0, "Tafsilotlar", isDark),
        _buildTab(1, "O'yinlar", isDark),
        _buildTab(2, "Jadval", isDark),
      ],
    );
  }

  Widget _buildTab(int index, String label, bool isDark) {
    bool isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isActive
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.white38 : Colors.black38),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              color: isActive
                  ? (isDark ? Colors.white : Colors.black)
                  : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
      TeamDetailedStats stats, List<LeagueStats> standings, bool isDark) {
    if (_selectedTabIndex == 0) {
      return _buildDetailsTab(stats, isDark);
    } else if (_selectedTabIndex == 1) {
      return _buildMatchesTab(isDark);
    } else {
      return _buildStandingsTab(standings, isDark);
    }
  }

  Widget _buildDetailsTab(TeamDetailedStats stats, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Next Match Card (if exists)
        if (stats.nextMatch != null) ...[
          _buildSectionTitle("Kelgusi o'yin", isDark),
          const SizedBox(height: 12),
          _buildMatchTile(stats.nextMatch!, isDark),
          const SizedBox(height: 24),
        ],

        // Recent Form (Bars)
        _buildSectionTitle("Oxirgi natijalar formasi", isDark),
        const SizedBox(height: 12),
        _buildRecentForm(stats.form, isDark),
        const SizedBox(height: 24),

        // Stats Grid
        _buildSectionTitle("Mavsum statistikasi", isDark),
        const SizedBox(height: 12),
        _buildStatsGrid(stats, isDark),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMatchesTab(bool isDark) {
    // Get all matches for this team
    final teamMatches = widget.tournament.matches
        .where(
            (m) => m.teamA?.id == widget.teamId || m.teamB?.id == widget.teamId)
        .toList();

    // Sort matches: played first (reversed round), then upcoming
    final played = teamMatches.where((m) => m.isPlayed).toList();
    played.sort((a, b) => b.round.compareTo(a.round));

    final upcoming = teamMatches.where((m) => !m.isPlayed).toList();
    upcoming.sort((a, b) => a.round.compareTo(b.round));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (played.isNotEmpty) ...[
          _buildSectionTitle("Natijalar", isDark),
          const SizedBox(height: 12),
          ...played.map((m) => _buildMatchTile(m, isDark)),
          const SizedBox(height: 24),
        ],
        if (upcoming.isNotEmpty) ...[
          _buildSectionTitle("Kelgusi o'yinlar", isDark),
          const SizedBox(height: 12),
          ...upcoming.map((m) => _buildMatchTile(m, isDark)),
          const SizedBox(height: 40),
        ],
      ],
    );
  }

  Widget _buildStandingsTab(List<LeagueStats> standings, bool isDark) {
    return GlassContainer(
      borderRadius: 12,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildStandingsHeader(isDark),
          Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
          // Rows
          ...standings.asMap().entries.map((entry) {
            int index = entry.key;
            LeagueStats s = entry.value;
            bool isMe = s.team.id == widget.teamId;
            bool isTop4 = index < 4;

            return Container(
              color: isMe
                  ? const Color(0xFF06DF5D).withOpacity(0.1)
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                      width: 25,
                      child: Text("${index + 1}",
                          style: GoogleFonts.outfit(
                              color: isTop4
                                  ? const Color(0xFF06DF5D)
                                  : (isDark ? Colors.white : Colors.black),
                              fontWeight: FontWeight.bold,
                              fontSize: 13))),
                  Expanded(
                      child: Text(
                    s.team.name,
                    style: GoogleFonts.outfit(
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  )),
                  _buildStatCell(s.played.toString(), isDark: isDark),
                  _buildStatCell(s.won.toString(), isDark: isDark),
                  _buildStatCell(s.drawn.toString(), isDark: isDark),
                  _buildStatCell(s.lost.toString(), isDark: isDark),
                  _buildStatCell("${s.goalsFor}:${s.goalsAgainst}",
                      isDark: isDark, width: 45),
                  _buildStatCell(s.points.toString(),
                      isDark: isDark,
                      isBold: true,
                      color: isDark ? Colors.white : Colors.black),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStandingsHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
              width: 25,
              child: Text("#",
                  style: GoogleFonts.outfit(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 11))),
          Expanded(
              child: Text("Jamoa",
                  style: GoogleFonts.outfit(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 11))),
          _buildStatCell("O'", isDark: isDark, isHeader: true),
          _buildStatCell("G'", isDark: isDark, isHeader: true),
          _buildStatCell("D", isDark: isDark, isHeader: true),
          _buildStatCell("M", isDark: isDark, isHeader: true),
          _buildStatCell("Gollar", isDark: isDark, isHeader: true, width: 45),
          _buildStatCell("OCH", isDark: isDark, isHeader: true),
        ],
      ),
    );
  }

  Widget _buildStatCell(String text,
      {required bool isDark,
      bool isHeader = false,
      bool isBold = false,
      double width = 25,
      Color? color}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(
          color: color ??
              (isHeader
                  ? (isDark ? Colors.white38 : Colors.black38)
                  : (isDark ? Colors.white70 : Colors.black87)),
          fontSize: isHeader ? 11 : 13,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        Icon(Icons.info_outline,
            color: isDark ? Colors.white24 : Colors.black26, size: 18),
      ],
    );
  }

  Widget _buildMatchTile(MatchModel match, bool isDark) {
    String dateStr = match.date != null
        ? DateFormat('dd.MM.yy HH:mm').format(match.date!)
        : "Round ${match.round}";
    bool isMeA = match.teamA?.id == widget.teamId;
    bool isMeB = match.teamB?.id == widget.teamId;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.sports_soccer,
                  size: 14, color: Color(0xFF06DF5D)),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              if (match.isPlayed)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: const Color(0xFF06DF5D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text("FT",
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF06DF5D),
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTeamRow(match.teamA!, isMeA, true, isDark),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  if (match.isPlayed)
                    Text("${match.scoreA} - ${match.scoreB}",
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: isDark ? Colors.white : Colors.black))
                  else
                    const Text("VS",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTeamRow(match.teamB!, isMeB, false, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRow(TeamModel team, bool isMe, bool isLeft, bool isDark) {
    return Row(
      mainAxisAlignment:
          isLeft ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isLeft) ...[
          CircleAvatar(
            radius: 14,
            backgroundColor: team.color.withOpacity(0.1),
            child: Icon(Icons.shield, color: team.color, size: 16),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            team.name,
            style: GoogleFonts.outfit(
                fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14),
            overflow: TextOverflow.ellipsis,
            textAlign: isLeft ? TextAlign.right : TextAlign.left,
          ),
        ),
        if (isLeft) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 14,
            backgroundColor: team.color.withOpacity(0.1),
            child: Icon(Icons.shield, color: team.color, size: 16),
          ),
        ],
      ],
    );
  }

  Widget _buildRecentForm(List<String> form, bool isDark) {
    return GlassContainer(
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      borderRadius: 16,
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: form.map((res) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (res == 'W') ...[
                      Container(
                        width: 40,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 45),
                    ] else if (res == 'L') ...[
                      const SizedBox(height: 45),
                      Container(
                        width: 40,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: 40,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ],
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: form
                .map((res) => Text(res,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white38 : Colors.black38)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(TeamDetailedStats stats, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard("G'alaba", stats.totalWins.toString(),
            const Color(0xFF06DF5D), isDark),
        _buildStatCard(
            "Durang", stats.totalDraws.toString(), Colors.blueAccent, isDark),
        _buildStatCard("Mag'lubiyat", stats.totalLosses.toString(),
            Colors.redAccent, isDark),
        _buildStatCard("Gollar", stats.totalGoalsScored.toString(),
            Colors.orangeAccent, isDark),
        _buildStatCard("Quruq o'yin", stats.cleanSheets.toString(),
            Colors.purpleAccent, isDark),
        _buildStatCard("O'rtacha gol", stats.avgGoalsScored.toStringAsFixed(1),
            Colors.tealAccent, isDark),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 13)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.outfit(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
