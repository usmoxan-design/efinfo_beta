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

    for (int round = 1; round <= numRounds; round++) {
      for (int i = 0; i < matchesPerRound; i++) {
        TeamModel? teamA = rotation[i];
        TeamModel? teamB = rotation[rotation.length - 1 - i];

        if (teamA != null && teamB != null) {
          matchIdCounter++;
          allMatches.add(MatchModel(
            id: matchIdCounter.toString(),
            teamA: teamA,
            teamB: teamB,
            round: round,
          ));
        }
      }
      // Rotate
      TeamModel? last = rotation.removeLast();
      rotation.insert(1, last);
    }

    // Double round-robin (Home/Away)
    if (tournament.leagueSettings?.isDoubleRound ?? false) {
      int firstHalfCount = allMatches.length;
      for (int i = 0; i < firstHalfCount; i++) {
        MatchModel m = allMatches[i];
        matchIdCounter++;
        allMatches.add(MatchModel(
          id: matchIdCounter.toString(),
          teamA: m.teamB,
          teamB: m.teamA,
          round: m.round + numRounds,
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
}
