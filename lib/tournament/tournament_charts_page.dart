import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/tournament/service/league_service.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class LeagueTournamentChartsPage extends StatelessWidget {
  final TournamentModel tournament;

  const LeagueTournamentChartsPage({
    super.key,
    required this.tournament,
  });

  @override
  Widget build(BuildContext context) {
    final leagueService = LeagueService();
    final stats = leagueService.getTournamentStats(tournament);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Tournament Statistics"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildGlobalSummary(stats),
            const SizedBox(height: 24),

            // Top Scoring Teams Chart
            _buildSectionTitle("Top Scoring Teams"),
            const SizedBox(height: 12),
            _buildGoalsChart(stats.topScoringTeams),
            const SizedBox(height: 32),

            // Wins/Losses Distribution (Optional: Pie Chart)
            _buildSectionTitle("Best Defenses (Goals Conceded)"),
            const SizedBox(height: 12),
            _buildDefenseChart(stats.bestDefenses),

            const SizedBox(height: 32),
            _buildSectionTitle("Top Wins"),
            const SizedBox(height: 12),
            _buildWinsList(stats.mostWins),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildGlobalSummary(TournamentStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [Colors.blue[900]!, Colors.blue[600]!]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
              "Matches", "${stats.matchesPlayed}/${stats.totalMatches}"),
          _buildSummaryItem("Total Goals", stats.totalGoals.toString()),
          _buildSummaryItem(
              "Avg Goals", stats.avgGoalsPerMatch.toStringAsFixed(2)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGoalsChart(List<LeagueStats> topScoring) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16)),
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
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10),
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
                  color: AppColors.accent,
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

  Widget _buildDefenseChart(List<LeagueStats> bestDefenses) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16)),
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
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10),
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

  Widget _buildWinsList(List<LeagueStats> mostWins) {
    return Column(
      children: mostWins.map((stats) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
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
                      style: const TextStyle(color: Colors.white))),
              Text("${stats.won} Wins",
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Removed local min
}
