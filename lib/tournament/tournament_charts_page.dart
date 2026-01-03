import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:efinfo_beta/tournament/service/league_service.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:provider/provider.dart';

class LeagueTournamentChartsPage extends StatelessWidget {
  final TournamentModel tournament;

  const LeagueTournamentChartsPage({
    super.key,
    required this.tournament,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final leagueService = LeagueService();
    final stats = leagueService.getTournamentStats(tournament);

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text(
          "Turnir Statistikasi",
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildGlobalSummary(stats, isDark),
            const SizedBox(height: 24),

            // Pie Charts Row
            Row(
              children: [
                Expanded(
                  child: _buildPieChartCard(
                    "O'yinlar natijasi",
                    [
                      PieChartSectionData(
                          value: stats.totalWins.toDouble(),
                          title: "G'alaba",
                          color: const Color(0xFF06DF5D),
                          radius: 50,
                          titleStyle: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      PieChartSectionData(
                          value: stats.totalDraws.toDouble(),
                          title: "Durang",
                          color: Colors.orangeAccent,
                          radius: 50,
                          titleStyle: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ],
                    isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPieChartCard(
                    "Gollar taqsimoti",
                    [
                      PieChartSectionData(
                          value: stats.homeGoals.toDouble(),
                          title: "Uy",
                          color: Colors.blueAccent,
                          radius: 50,
                          titleStyle: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      PieChartSectionData(
                          value: stats.awayGoals.toDouble(),
                          title: "Mehmon",
                          color: Colors.purpleAccent,
                          radius: 50,
                          titleStyle: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top Scoring Teams Chart
            _buildSectionTitle("Eng ko'p gol urgan jamoalar", isDark),
            const SizedBox(height: 12),
            _buildGoalsChart(stats.topScoringTeams, isDark),
            const SizedBox(height: 32),

            // Wins/Losses Distribution (Optional: Pie Chart)
            _buildSectionTitle(
                "Eng yaxshi himoyalar (O'tkazilgan gollar)", isDark),
            const SizedBox(height: 12),
            _buildDefenseChart(stats.bestDefenses, isDark),

            const SizedBox(height: 32),
            _buildSectionTitle("G'alabalar", isDark),
            const SizedBox(height: 12),
            _buildWinsList(stats.mostWins, isDark),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.outfit(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold),
    );
  }

  Widget _buildGlobalSummary(TournamentStats stats, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            const Color(0xFF06DF5D).withOpacity(0.2),
            Colors.blueAccent.withOpacity(0.2)
          ]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem("O'yinlar",
                "${stats.matchesPlayed}/${stats.totalMatches}", isDark),
            _buildSummaryItem("Gollar", stats.totalGoals.toString(), isDark),
            _buildSummaryItem(
                "O'rtacha", stats.avgGoalsPerMatch.toStringAsFixed(2), isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.outfit(
                color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGoalsChart(List<LeagueStats> topScoring, bool isDark) {
    return GlassContainer(
      height: 250,
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (topScoring.isEmpty ? 10 : topScoring.first.goalsFor * 1.2)
              .toDouble(),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx >= 0 && idx < topScoring.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        topScoring[idx].team.name.substring(
                            0, min(3, topScoring[idx].team.name.length)),
                        style: GoogleFonts.outfit(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: topScoring.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.goalsFor.toDouble(),
                  color: const Color(0xFF06DF5D),
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDefenseChart(List<LeagueStats> bestDefenses, bool isDark) {
    return GlassContainer(
      height: 200,
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              (bestDefenses.isEmpty ? 10 : bestDefenses.last.goalsAgainst * 1.2)
                  .toDouble(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx >= 0 && idx < bestDefenses.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        bestDefenses[idx].team.name.substring(
                            0, min(3, bestDefenses[idx].team.name.length)),
                        style: GoogleFonts.outfit(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: bestDefenses.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.goalsAgainst.toDouble(),
                  color: Colors.red[400]!,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWinsList(List<LeagueStats> mostWins, bool isDark) {
    return Column(
      children: mostWins.map((stats) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: GlassContainer(
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: stats.team.color.withOpacity(0.2),
                  child: Icon(Icons.shield, color: stats.team.color, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(stats.team.name,
                        style: GoogleFonts.outfit(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600))),
                Text("${stats.won} G'alaba",
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF06DF5D),
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPieChartCard(
      String title, List<PieChartSectionData> sections, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        children: [
          Text(title,
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 20,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Removed local min
}
