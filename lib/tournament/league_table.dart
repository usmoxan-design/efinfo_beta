import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/tournament/match_model.dart';
import 'package:efinfo_beta/tournament/service/league_service.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:flutter/material.dart';

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
    return Row(
      children: [
        _buildTabButton('all', 'All'),
        const SizedBox(width: 8),
        _buildTabButton('home', 'Home'),
        const SizedBox(width: 8),
        _buildTabButton('away', 'Away'),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: const [
              Icon(Icons.show_chart, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text("Chart",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
        ),
      ],
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
    return Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: const [
                SizedBox(
                    width: 30,
                    child: Text("#",
                        style: TextStyle(color: Colors.grey, fontSize: 13))),
                Expanded(
                    child: Text("Team",
                        style: TextStyle(color: Colors.grey, fontSize: 13))),
                SizedBox(
                    width: 30,
                    child: Text("P",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13))),
                SizedBox(
                    width: 30,
                    child: Text("W",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13))),
                SizedBox(
                    width: 30,
                    child: Text("D",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13))),
                SizedBox(
                    width: 30,
                    child: Text("L",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13))),
                SizedBox(
                    width: 50,
                    child: Text("Goals",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13))),
                SizedBox(
                    width: 35,
                    child: Text("PTS",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13))),
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

            return Container(
              color:
                  isFirst ? Colors.green.withOpacity(0.15) : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: isTop4 || is5th
                        ? CircleAvatar(
                            radius: 11,
                            backgroundColor:
                                isTop4 ? Colors.green[700] : Colors.blue[800],
                            child: Text("${index + 1}",
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text("${index + 1}",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      stats.team.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                      width: 30,
                      child: Text("${stats.played}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14))),
                  SizedBox(
                      width: 30,
                      child: Text("${stats.won}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: stats.won > 0
                                  ? Colors.red[700]
                                  : Colors.black,
                              fontSize: 14))),
                  SizedBox(
                      width: 30,
                      child: Text("${stats.drawn}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14))),
                  SizedBox(
                      width: 30,
                      child: Text("${stats.lost}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14))),
                  SizedBox(
                      width: 50,
                      child: Text("${stats.goalsFor}:${stats.goalsAgainst}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 13))),
                  SizedBox(
                      width: 35,
                      child: Text("${stats.points}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 14))),
                ],
              ),
            );
          }).toList(),
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
              "$_currentRound-Round",
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
        child: Row(
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
                  match.isPlayed ? "${match.scoreA} : ${match.scoreB}" : "vs",
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
      ),
    );
  }
}
