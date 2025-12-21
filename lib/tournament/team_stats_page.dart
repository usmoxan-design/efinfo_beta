import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/tournament/match_model.dart';
import 'package:efinfo_beta/tournament/service/league_service.dart';
import 'package:efinfo_beta/tournament/team_model.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
    final stats =
        _leagueService.getTeamDetailedStats(widget.tournament, widget.teamId);
    final standings = _leagueService.calculateStandings(widget.tournament);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark blue/slate
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(stats.team.name,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Header: Logo / Info (Cleaned as requested)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildTeamHeader(stats),
          ),

          // Tabs
          _buildInternalTabs(),

          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildTabContent(stats, standings),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamHeader(TeamDetailedStats stats) {
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
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Text(
                  "League Participant",
                  style:
                      GoogleFonts.outfit(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInternalTabs() {
    return Row(
      children: [
        _buildTab(0, "Details"),
        _buildTab(1, "Matches"),
        _buildTab(2, "Standings"),
      ],
    );
  }

  Widget _buildTab(int index, String label) {
    bool isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              color: isActive ? Colors.white : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
      TeamDetailedStats stats, List<LeagueStats> standings) {
    if (_selectedTabIndex == 0) {
      return _buildDetailsTab(stats);
    } else if (_selectedTabIndex == 1) {
      return _buildMatchesTab();
    } else {
      return _buildStandingsTab(standings);
    }
  }

  Widget _buildDetailsTab(TeamDetailedStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Next Match Card (if exists)
        if (stats.nextMatch != null) ...[
          _buildSectionTitle("Upcoming Match"),
          const SizedBox(height: 12),
          _buildMatchTile(stats.nextMatch!),
          const SizedBox(height: 24),
        ],

        // Recent Form (Bars)
        _buildSectionTitle("Recent form"),
        const SizedBox(height: 12),
        _buildRecentForm(stats.form),
        const SizedBox(height: 24),

        // Stats Grid
        _buildSectionTitle("Season Stats"),
        const SizedBox(height: 12),
        _buildStatsGrid(stats),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMatchesTab() {
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
        if (upcoming.isNotEmpty) ...[
          _buildSectionTitle("Upcoming"),
          const SizedBox(height: 12),
          ...upcoming.map((m) => _buildMatchTile(m)),
          const SizedBox(height: 24),
        ],
        if (played.isNotEmpty) ...[
          _buildSectionTitle("Results"),
          const SizedBox(height: 12),
          ...played.map((m) => _buildMatchTile(m)),
          const SizedBox(height: 40),
        ],
      ],
    );
  }

  Widget _buildStandingsTab(List<LeagueStats> standings) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildStandingsHeader(),
          const Divider(height: 1),
          // Rows
          ...standings.asMap().entries.map((entry) {
            int index = entry.key;
            LeagueStats s = entry.value;
            bool isMe = s.team.id == widget.teamId;
            bool isTop4 = index < 4;

            return Container(
              color: isMe ? Colors.blue.withOpacity(0.1) : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                      width: 25,
                      child: Text("${index + 1}",
                          style: TextStyle(
                              color: isTop4 ? Colors.green[700] : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13))),
                  Expanded(
                      child: Text(
                    s.team.name,
                    style: GoogleFonts.outfit(
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                        color: Colors.black,
                        fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  )),
                  _buildStatCell(s.played.toString()),
                  _buildStatCell(s.won.toString()),
                  _buildStatCell(s.drawn.toString()),
                  _buildStatCell(s.lost.toString()),
                  _buildStatCell("${s.goalsFor}:${s.goalsAgainst}", width: 45),
                  _buildStatCell(s.points.toString(), isBold: true),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStandingsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const SizedBox(
              width: 25,
              child: Text("#",
                  style: TextStyle(color: Colors.grey, fontSize: 11))),
          const Expanded(
              child: Text("Team",
                  style: TextStyle(color: Colors.grey, fontSize: 11))),
          _buildStatCell("P", isHeader: true),
          _buildStatCell("W", isHeader: true),
          _buildStatCell("D", isHeader: true),
          _buildStatCell("L", isHeader: true),
          _buildStatCell("Goals", isHeader: true, width: 45),
          _buildStatCell("PTS", isHeader: true),
        ],
      ),
    );
  }

  Widget _buildStatCell(String text,
      {bool isHeader = false, bool isBold = false, double width = 25}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isHeader ? Colors.grey : Colors.black,
          fontSize: isHeader ? 11 : 13,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Icon(Icons.info_outline, color: Colors.grey, size: 18),
      ],
    );
  }

  Widget _buildMatchTile(MatchModel match) {
    String dateStr = match.date != null
        ? DateFormat('dd.MM.yy HH:mm').format(match.date!)
        : "Round ${match.round}";
    bool isMeA = match.teamA?.id == widget.teamId;
    bool isMeB = match.teamB?.id == widget.teamId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.sports_soccer, size: 14, color: Colors.blue),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: GoogleFonts.outfit(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              if (match.isPlayed)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10)),
                  child: Text("FT",
                      style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTeamRow(match.teamA!, isMeA, true),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  if (match.isPlayed)
                    Text("${match.scoreA} - ${match.scoreB}",
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black))
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
                child: _buildTeamRow(match.teamB!, isMeB, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRow(TeamModel team, bool isMe, bool isLeft) {
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
                color: Colors.black,
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

  Widget _buildRecentForm(List<String> form) {
    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
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
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: form
                .map((res) => Text(res,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, color: Colors.black54)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(TeamDetailedStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard("Wins", stats.totalWins.toString(), Colors.green),
        _buildStatCard("Draws", stats.totalDraws.toString(), Colors.blue),
        _buildStatCard("Losses", stats.totalLosses.toString(), Colors.red),
        _buildStatCard(
            "Goals", stats.totalGoalsScored.toString(), Colors.orange),
        _buildStatCard(
            "Clean Sheets", stats.cleanSheets.toString(), Colors.purple),
        _buildStatCard(
            "Avg Goals", stats.avgGoalsScored.toStringAsFixed(1), Colors.teal),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.outfit(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
