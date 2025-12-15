import 'package:efinfo_beta/tournament/match_model.dart';
import 'package:efinfo_beta/tournament/team_model.dart';

import 'dart:math';

import 'package:efinfo_beta/tournament/tournament_model.dart';

class BracketService {
  static int getNextPowerOfTwo(int n) {
    if (n <= 1) return 2;
    int power = 1;
    while (power < n) {
      power *= 2;
    }
    return power;
  }

  // --- 1. createBracket(): Qura Tashlash va To'liq Bracketni Yaratish (Yakuniy versiya) ---
  TournamentModel createBracket(TournamentModel tournament) {
    if (tournament.isDrawDone) return tournament;

    if (tournament.teams.length < 2 || tournament.teams.length % 2 != 0) {
      throw Exception(
          "Ishtirokchilar soni juft va kamida 2 ta bo'lishi kerak.");
    }

    List<TeamModel> shuffledTeams = List.from(tournament.teams);
    shuffledTeams.shuffle(Random());

    final totalTeams = shuffledTeams.length;
    final requiredSlots = getNextPowerOfTwo(totalTeams);
    final finalMatchRound = log(requiredSlots) ~/ log(2);

    List<MatchModel> allMatches = [];
    int matchIdCounter = 0;

    // 1. Barcha Matchlarni Raundlar tartibida yaratish
    for (int r = 1; r <= finalMatchRound; r++) {
      final matchesInRound = (requiredSlots ~/ pow(2, r)).toInt();

      for (int i = 0; i < matchesInRound; i++) {
        matchIdCounter++;
        allMatches.add(MatchModel(
          id: matchIdCounter.toString(),
          round: r,
        ));
      }
    }

    // Raundlar bo'yicha guruhlash (bog'lanish uchun qulaylik)
    Map<int, List<MatchModel>> matchesByRound = {};
    for (var match in allMatches) {
      if (!matchesByRound.containsKey(match.round)) {
        matchesByRound[match.round] = [];
      }
      matchesByRound[match.round]!.add(match);
    }

    // 2. Matchlarni keyingi raundga bog'lash
    for (int r = 1; r < finalMatchRound; r++) {
      final currentRoundMatches = matchesByRound[r] ?? [];
      final nextRoundMatches = matchesByRound[r + 1] ?? [];

      if (currentRoundMatches.isEmpty || nextRoundMatches.isEmpty) continue;

      for (int i = 0; i < currentRoundMatches.length; i += 2) {
        // nextMatch har doim keyingi raunddagi juftlikning yangi o'yini bo'ladi
        final nextMatch = nextRoundMatches[i ~/ 2];

        // 1-match (i)
        currentRoundMatches[i].nextMatchId = int.parse(nextMatch.id);
        currentRoundMatches[i].nextTeamSlot = 0;

        // 2-match (i+1)
        if (i + 1 < currentRoundMatches.length) {
          currentRoundMatches[i + 1].nextMatchId = int.parse(nextMatch.id);
          currentRoundMatches[i + 1].nextTeamSlot = 1;
        }
      }
    }

    // 3. 1-Raund matchlariga jamoalarni joylashtirish
    final firstRoundMatches = matchesByRound[1] ?? [];
    final initialMatchesCount = firstRoundMatches.length;

    for (int i = 0; i < initialMatchesCount; i++) {
      firstRoundMatches[i].teamA = shuffledTeams[i * 2];
      firstRoundMatches[i].teamB = shuffledTeams[i * 2 + 1];
    }

    tournament.matches = allMatches;
    tournament.isDrawDone = true;
    return tournament;
  }

  // --- 2. reportMatchResult() ---
  TournamentModel reportMatchResult(
      TournamentModel tournament, String matchId, int scoreA, int scoreB) {
    try {
      final matchIndex = tournament.matches.indexWhere((m) => m.id == matchId);
      if (matchIndex == -1) {
        throw Exception("Match topilmadi.");
      }

      MatchModel match = tournament.matches[matchIndex];
      if (match.teamA == null || match.teamB == null) {
        throw Exception("O'yin hali boshlanmagan (bo'sh o'rin).");
      }

      match.scoreA = scoreA;
      match.scoreB = scoreB;
      match.determineWinner();

      if (match.winnerId == null) {
        throw Exception("Durang natija mumkin emas. G'olibni aniqlang.");
      }

      return updateBracket(tournament, match);
    } catch (e) {
      rethrow;
    }
  }

  // --- 3. updateBracket() ---
  TournamentModel updateBracket(
      TournamentModel tournament, MatchModel completedMatch) {
    if (completedMatch.winnerId == null) return tournament;

    final winnerTeam =
        tournament.teams.firstWhere((t) => t.id == completedMatch.winnerId);

    if (completedMatch.nextMatchId != null) {
      final nextMatchId = completedMatch.nextMatchId.toString();
      final nextSlot = completedMatch.nextTeamSlot;

      final nextMatchIndex =
          tournament.matches.indexWhere((m) => m.id == nextMatchId);

      if (nextMatchIndex != -1) {
        MatchModel nextMatch = tournament.matches[nextMatchIndex];

        if (nextSlot == 0) {
          nextMatch.teamA = winnerTeam;
        } else if (nextSlot == 1) {
          nextMatch.teamB = winnerTeam;
        }
      }
    }

    final totalTeams = tournament.teams.length;
    final requiredSlots = getNextPowerOfTwo(totalTeams);
    final finalMatchRound = log(requiredSlots) ~/ log(2);

    MatchModel? finalMatch;
    try {
      finalMatch =
          tournament.matches.firstWhere((m) => m.round == finalMatchRound);
    } catch (_) {}

    if (finalMatch != null && finalMatch.winnerId != null) {
      tournament.championId = finalMatch.winnerId;
    }

    return tournament;
  }

  // --- 4. 3-O'rin Uchrashuvini Yaratish ---
  TournamentModel createThirdPlaceMatch(TournamentModel tournament) {
    if (tournament.matches.any((m) => m.round == 99) ||
        tournament.championId != null) {
      return tournament;
    }

    final finalRound =
        log(getNextPowerOfTwo(tournament.teams.length)) ~/ log(2);
    final semiFinalRound = finalRound - 1;

    if (!tournament.matches.any((m) => m.round == semiFinalRound))
      return tournament;

    List<MatchModel> semiFinalMatches =
        tournament.matches.where((m) => m.round == semiFinalRound).toList();

    if (semiFinalMatches.length != 2 ||
        !semiFinalMatches.every((m) => m.winnerId != null)) return tournament;

    List<TeamModel?> losers = [];
    for (var match in semiFinalMatches) {
      String? loserId;
      if (match.winnerId == match.teamA?.id) {
        loserId = match.teamB?.id;
      } else if (match.winnerId == match.teamB?.id) {
        loserId = match.teamA?.id;
      }

      if (loserId != null) {
        losers.add(tournament.teams.firstWhere((t) => t.id == loserId));
      }
    }

    if (losers.length == 2 && losers[0] != null && losers[1] != null) {
      MatchModel thirdPlaceMatch = MatchModel(
        id: '999',
        round: 99,
        teamA: losers[0],
        teamB: losers[1],
      );
      tournament.matches.add(thirdPlaceMatch);
    }
    return tournament;
  }

  // --- Yordamchi Funksiya: Raund Sarlavhasini Olish ---
  String getRoundTitle(int round, int totalRounds) {
    if (round == 99) return "3-O'rin Uchrashuvi";
    if (round == totalRounds) return "Final";
    if (round == totalRounds - 1) return "Yarim Final";
    if (round == totalRounds - 2) return "Chorak Final";
    if (round == 1 && totalRounds >= 4)
      return "1/${pow(2, totalRounds - 1).toInt()} Final";
    return "$round-Raund";
  }
}
