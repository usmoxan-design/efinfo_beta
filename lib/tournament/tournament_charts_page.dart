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
            _buildGlobalSummary(stats, isDark),
            const SizedBox(height: 24),
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
            _buildSectionTitle("Eng ko'p gol urganlar", isDark),
            const SizedBox(height: 12),
            _buildLineChart(stats.topScoringTeams, true, isDark),
            const SizedBox(height: 32),
            _buildSectionTitle(
                "Eng yaxshi himoyalar (O'tkazilgan gollar)", isDark),
            const SizedBox(height: 12),
            _buildLineChart(stats.bestDefenses, false, isDark),
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

  Widget _buildLineChart(
      List<LeagueStats> stats, bool isGoalsFor, bool isDark) {
    if (stats.isEmpty) return const SizedBox();

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? Colors.white12 : Colors.black12,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= stats.length)
                          return const SizedBox();
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            stats[index].team.name.substring(
                                0, min(5, stats[index].team.name.length)),
                            style: GoogleFonts.outfit(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value.toInt().toString(),
                            style: GoogleFonts.outfit(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: stats.asMap().entries.map((entry) {
                      int idx = entry.key;
                      int val = isGoalsFor
                          ? entry.value.goalsFor
                          : entry.value.goalsAgainst;
                      return FlSpot(idx.toDouble(), val.toDouble());
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: isGoalsFor
                          ? [const Color(0xFF06DF5D), Colors.blueAccent]
                          : [Colors.redAccent, Colors.orangeAccent],
                    ),
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: isGoalsFor
                            ? [
                                const Color(0xFF06DF5D).withOpacity(0.2),
                                Colors.blueAccent.withOpacity(0.0)
                              ]
                            : [
                                Colors.redAccent.withOpacity(0.2),
                                Colors.orangeAccent.withOpacity(0.0)
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...stats.map((s) {
            int val = isGoalsFor ? s.goalsFor : s.goalsAgainst;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isGoalsFor
                          ? const Color(0xFF06DF5D)
                          : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(s.team.name,
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black87)),
                  ),
                  Text(val.toString(),
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black)),
                ],
              ),
            );
          }),
        ],
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
}
