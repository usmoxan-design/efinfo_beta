import 'package:efinfo_beta/tournament/match_model.dart';
import 'package:efinfo_beta/tournament/team_model.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';

class LeagueStats {
  final TeamModel team;
  int played = 0;
  int won = 0;
  int drawn = 0;
  int lost = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;
  int points = 0;

  int get goalDifference => goalsFor - goalsAgainst;

  LeagueStats(this.team);
}

class TeamDetailedStats {
  final TeamModel team;
  final List<String> form; // ['W', 'L', 'D', ...]
  final List<MatchModel> recentMatches;
  final MatchModel? nextMatch;
  final int cleanSheets;
  final double avgGoalsScored;
  final double avgGoalsConceded;
  final int totalWins;
  final int totalDraws;
  final int totalLosses;
  final int totalGoalsScored;
  final int totalGoalsConceded;

  TeamDetailedStats({
    required this.team,
    required this.form,
    required this.recentMatches,
    this.nextMatch,
    required this.cleanSheets,
    required this.avgGoalsScored,
    required this.avgGoalsConceded,
    required this.totalWins,
    required this.totalDraws,
    required this.totalLosses,
    required this.totalGoalsScored,
    required this.totalGoalsConceded,
  });
}

class TournamentStats {
  final List<LeagueStats> topScoringTeams;
  final List<LeagueStats> bestDefenses;
  final List<LeagueStats> mostWins;
  final List<LeagueStats> mostLosses;
  final int totalGoals;
  final int homeGoals;
  final int awayGoals;
  final double avgGoalsPerMatch;
  final int matchesPlayed;
  final int totalMatches;
  final int totalWins;
  final int totalDraws;

  TournamentStats({
    required this.topScoringTeams,
    required this.bestDefenses,
    required this.mostWins,
    required this.mostLosses,
    required this.totalGoals,
    required this.homeGoals,
    required this.awayGoals,
    required this.avgGoalsPerMatch,
    required this.matchesPlayed,
    required this.totalMatches,
    required this.totalWins,
    required this.totalDraws,
  });
}

class LeagueService {
  // --- 1. createLeague(): Round-robin scheduling ---
  TournamentModel createLeague(TournamentModel tournament) {
    if (tournament.isDrawDone) return tournament;

    List<TeamModel> teams = List.from(tournament.teams);
    if (teams.isEmpty) return tournament;

    bool hasBye = false;
    if (teams.length % 2 != 0) {
      hasBye = true;
    }

    int numTeams = teams.length;
    int numRounds = hasBye ? numTeams : numTeams - 1;
    int matchesPerRound = (numTeams + (hasBye ? 1 : 0)) ~/ 2;

    List<MatchModel> allMatches = [];
    int matchIdCounter = 0;

    List<TeamModel?> rotation = List.from(teams);
    if (hasBye) rotation.add(null);

    final settings = tournament.leagueSettings;
    final bool autoSchedule = settings?.isAutoSchedule ?? false;
    final int interval = settings?.daysInterval ?? 1;
    final int startH = settings?.startHour ?? 18;
    final int endH = settings?.endHour ?? 22;

    final DateTime now = DateTime.now();
    final DateTime baseDate = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1)); // Ertadan boshlanadi

    for (int round = 1; round <= numRounds; round++) {
      DateTime roundDate = baseDate.add(Duration(days: (round - 1) * interval));
      for (int i = 0; i < matchesPerRound; i++) {
        TeamModel? teamA = rotation[i];
        TeamModel? teamB = rotation[rotation.length - 1 - i];

        if (teamA != null && teamB != null) {
          matchIdCounter++;
          DateTime? matchDate;
          if (autoSchedule) {
            int h = startH + (endH > startH ? (i % (endH - startH)) : 0);
            int m = (i * 15) % 60;
            matchDate =
                DateTime(roundDate.year, roundDate.month, roundDate.day, h, m);
          }

          allMatches.add(MatchModel(
            id: matchIdCounter.toString(),
            teamA: teamA,
            teamB: teamB,
            round: round,
            date: matchDate,
          ));
        }
      }
      // Rotate
      TeamModel? last = rotation.removeLast();
      rotation.insert(1, last);
    }

    // Double round-robin (Home/Away)
    if (settings?.isDoubleRound ?? false) {
      int firstHalfCount = allMatches.length;
      for (int i = 0; i < firstHalfCount; i++) {
        MatchModel m = allMatches[i];
        matchIdCounter++;

        DateTime? matchDate;
        if (autoSchedule && m.date != null) {
          matchDate = m.date!.add(Duration(days: numRounds * interval));
        }

        allMatches.add(MatchModel(
          id: matchIdCounter.toString(),
          teamA: m.teamB,
          teamB: m.teamA,
          round: m.round + numRounds,
          date: matchDate,
        ));
      }
    }

    tournament.matches = allMatches;
    tournament.isDrawDone = true;
    return tournament;
  }

  // --- 2. calculateStandings() ---
  List<LeagueStats> calculateStandings(TournamentModel tournament,
      {String mode = 'all'}) {
    Map<String, LeagueStats> statsMap = {
      for (var team in tournament.teams) team.id: LeagueStats(team)
    };

    for (var match in tournament.matches) {
      if (!match.isPlayed || match.teamA == null || match.teamB == null)
        continue;

      LeagueStats? homeStats = statsMap[match.teamA!.id];
      LeagueStats? awayStats = statsMap[match.teamB!.id];

      if (homeStats == null || awayStats == null) continue;

      // Filter by mode
      bool processHome = mode == 'all' || mode == 'home';
      bool processAway = mode == 'all' || mode == 'away';

      if (processHome) {
        homeStats.played++;
        homeStats.goalsFor += match.scoreA;
        homeStats.goalsAgainst += match.scoreB;
        if (match.scoreA > match.scoreB) {
          homeStats.won++;
          homeStats.points += 3;
        } else if (match.scoreA == match.scoreB) {
          homeStats.drawn++;
          homeStats.points += 1;
        } else {
          homeStats.lost++;
        }
      }

      if (processAway) {
        awayStats.played++;
        awayStats.goalsFor += match.scoreB;
        awayStats.goalsAgainst += match.scoreA;
        if (match.scoreB > match.scoreA) {
          awayStats.won++;
          awayStats.points += 3;
        } else if (match.scoreA == match.scoreB) {
          awayStats.drawn++;
          awayStats.points += 1;
        } else {
          awayStats.lost++;
        }
      }
    }

    List<LeagueStats> result = statsMap.values.toList();

    // Sort: Points > GD > GF
    result.sort((a, b) {
      if (b.points != a.points) return b.points.compareTo(a.points);
      if (b.goalDifference != a.goalDifference)
        return b.goalDifference.compareTo(a.goalDifference);
      return b.goalsFor.compareTo(a.goalsFor);
    });

    return result;
  }

  // --- 3. reportMatchResult() ---
  TournamentModel reportMatchResult(
      TournamentModel tournament, String matchId, int scoreA, int scoreB) {
    int index = tournament.matches.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      tournament.matches[index].scoreA = scoreA;
      tournament.matches[index].scoreB = scoreB;
      tournament.matches[index].isPlayed = true;
      tournament.matches[index].determineWinner();

      // Check if all matches are played to determine champion
      bool allPlayed = tournament.matches.every((m) => m.isPlayed);
      if (allPlayed) {
        List<LeagueStats> standings = calculateStandings(tournament);
        if (standings.isNotEmpty) {
          tournament.championId = standings.first.team.id;
        }
      } else {
        tournament.championId = null; // Re-calculate if result changed
      }
    }
    return tournament;
  }

  // --- 4. getTeamDetailedStats(): Get details for a specific team ---
  TeamDetailedStats getTeamDetailedStats(
      TournamentModel tournament, String teamId) {
    TeamModel team = tournament.teams.firstWhere((t) => t.id == teamId);

    List<MatchModel> teamMatches = tournament.matches
        .where((m) => m.teamA?.id == teamId || m.teamB?.id == teamId)
        .toList();

    List<MatchModel> playedMatches =
        teamMatches.where((m) => m.isPlayed).toList();
    playedMatches.sort((a, b) => b.round.compareTo(a.round)); // Recent first

    List<String> form = [];
    int cleanSheets = 0;
    int totalWins = 0;
    int totalDraws = 0;
    int totalLosses = 0;
    int totalGoalsScored = 0;
    int totalGoalsConceded = 0;

    for (var match in playedMatches) {
      bool isHome = match.teamA?.id == teamId;
      int myScore = isHome ? match.scoreA : match.scoreB;
      int opScore = isHome ? match.scoreB : match.scoreA;

      totalGoalsScored += myScore;
      totalGoalsConceded += opScore;

      if (opScore == 0) cleanSheets++;

      if (myScore > opScore) {
        form.add('W');
        totalWins++;
      } else if (myScore == opScore) {
        form.add('D');
        totalDraws++;
      } else {
        form.add('L');
        totalLosses++;
      }
    }

    MatchModel? nextMatch;
    try {
      List<MatchModel> upcoming =
          teamMatches.where((m) => !m.isPlayed).toList();
      upcoming.sort((a, b) => a.round.compareTo(b.round));
      if (upcoming.isNotEmpty) nextMatch = upcoming.first;
    } catch (_) {}

    int playedCount = playedMatches.length;
    return TeamDetailedStats(
      team: team,
      form: form.reversed.toList(), // Chronological
      recentMatches: playedMatches.take(5).toList(),
      nextMatch: nextMatch,
      cleanSheets: cleanSheets,
      avgGoalsScored: playedCount > 0 ? totalGoalsScored / playedCount : 0,
      avgGoalsConceded: playedCount > 0 ? totalGoalsConceded / playedCount : 0,
      totalWins: totalWins,
      totalDraws: totalDraws,
      totalLosses: totalLosses,
      totalGoalsScored: totalGoalsScored,
      totalGoalsConceded: totalGoalsConceded,
    );
  }

  // --- 5. getTournamentStats(): Global statistics ---
  TournamentStats getTournamentStats(TournamentModel tournament) {
    List<LeagueStats> standings = calculateStandings(tournament);

    List<LeagueStats> topScoring = List.from(standings);
    topScoring.sort((a, b) => b.goalsFor.compareTo(a.goalsFor));

    List<LeagueStats> bestDefenses = List.from(standings);
    bestDefenses.sort((a, b) => a.goalsAgainst.compareTo(b.goalsAgainst));

    List<LeagueStats> mostWins = List.from(standings);
    mostWins.sort((a, b) => b.won.compareTo(a.won));

    List<LeagueStats> mostLosses = List.from(standings);
    mostLosses.sort((a, b) => b.lost.compareTo(a.lost));

    int totalGoals = 0;
    int homeGoals = 0;
    int awayGoals = 0;
    int playedMatches = 0;
    int totalWins = 0;
    int totalDraws = 0;

    for (var m in tournament.matches) {
      if (m.isPlayed) {
        totalGoals += (m.scoreA + m.scoreB);
        homeGoals += m.scoreA;
        awayGoals += m.scoreB;
        playedMatches++;
        if (m.scoreA == m.scoreB) {
          totalDraws++;
        } else {
          totalWins++;
        }
      }
    }

    return TournamentStats(
      topScoringTeams: topScoring.take(5).toList(),
      bestDefenses: bestDefenses.take(5).toList(),
      mostWins: mostWins.take(5).toList(),
      mostLosses: mostLosses.take(5).toList(),
      totalGoals: totalGoals,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      avgGoalsPerMatch: playedMatches > 0 ? totalGoals / playedMatches : 0,
      matchesPlayed: playedMatches,
      totalMatches: tournament.matches.length,
      totalWins: totalWins,
      totalDraws: totalDraws,
    );
  }
}
