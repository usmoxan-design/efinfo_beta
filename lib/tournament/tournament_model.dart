// import 'package:flutter/material.dart';
// import 'dart:convert';

// // --- Asosiy Modellar ---

// class PlayerModel {
//   String name;
//   Color color;
//   String id;

//   PlayerModel(this.name, this.color, {String? id})
//       : id = id ?? UniqueKey().toString();

//   Map<String, dynamic> toJson() => {
//         'name': name,
//         'colorValue': color.value,
//         'id': id,
//       };

//   factory PlayerModel.fromJson(Map<String, dynamic> json) {
//     return PlayerModel(
//       json['name'] as String,
//       Color(json['colorValue'] as int),
//       id: json['id'] as String,
//     );
//   }
// }

// // --- O'yin Modeli (Match Model) ---

// class MatchModel {
//   String id;
//   PlayerModel? playerA;
//   PlayerModel? playerB;
//   int scoreA;
//   int scoreB;
//   String? winnerId; // Match g'olibi ID si
//   int round; // Chorak final = 1, Yarim final = 2, Final = 3

//   MatchModel({
//     required this.id,
//     this.playerA,
//     this.playerB,
//     this.scoreA = 0,
//     this.scoreB = 0,
//     this.winnerId,
//     required this.round,
//   });

//   // G'olibni aniqlash mantig'i
//   void determineWinner() {
//     if (playerA == null || playerB == null) return;
//     if (scoreA > scoreB) {
//       winnerId = playerA!.id;
//     } else if (scoreB > scoreA) {
//       winnerId = playerB!.id;
//     } else {
//       winnerId = null; // Durang (yoki qayta o'ynaladi, hozircha null)
//     }
//   }

//   // Serializatsiya
//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'playerA': playerA?.toJson(),
//         'playerB': playerB?.toJson(),
//         'scoreA': scoreA,
//         'scoreB': scoreB,
//         'winnerId': winnerId,
//         'round': round,
//       };

//   // Deserializatsiya
//   factory MatchModel.fromJson(Map<String, dynamic> json) {
//     return MatchModel(
//       id: json['id'] as String,
//       playerA: json['playerA'] != null
//           ? PlayerModel.fromJson(json['playerA'] as Map<String, dynamic>)
//           : null,
//       playerB: json['playerB'] != null
//           ? PlayerModel.fromJson(json['playerB'] as Map<String, dynamic>)
//           : null,
//       scoreA: json['scoreA'] as int,
//       scoreB: json['scoreB'] as int,
//       winnerId: json['winnerId'] as String?,
//       round: json['round'] as int,
//     );
//   }
// }

// // --- Turnir Modeli ---

// class TournamentModel {
//   String name;
//   List<PlayerModel> players;
//   String id;
//   bool isDrawDone; // Qura tashlanganmi?
//   List<MatchModel> matches; // Barcha o'yinlar

//   TournamentModel({
//     required this.name,
//     required this.players,
//     String? id,
//     this.isDrawDone = false,
//     List<MatchModel>? matches,
//   })  : id = id ?? UniqueKey().toString(),
//         matches = matches ?? [];

//   // Serializatsiya
//   Map<String, dynamic> toJson() => {
//         'name': name,
//         'players': players.map((p) => p.toJson()).toList(),
//         'id': id,
//         'isDrawDone': isDrawDone,
//         'matches': matches.map((m) => m.toJson()).toList(),
//       };

//   // Deserializatsiya
//   factory TournamentModel.fromJson(Map<String, dynamic> json) {
//     var playersList = json['players'] as List;
//     List<PlayerModel> players =
//         playersList.map((i) => PlayerModel.fromJson(i as Map<String, dynamic>)).toList();

//     var matchesList = json['matches'] as List;
//     List<MatchModel> matches =
//         matchesList.map((i) => MatchModel.fromJson(i as Map<String, dynamic>)).toList();

//     return TournamentModel(
//       name: json['name'] as String,
//       players: players,
//       id: json['id'] as String,
//       isDrawDone: json['isDrawDone'] as bool,
//       matches: matches,
//     );
//   }
// }

import 'team_model.dart';
import 'match_model.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

enum TournamentType { knockout, league }

class LeagueSettings {
  final bool isDoubleRound; // Uy-mehmon o'yinlari bormi?
  final bool isAutoSchedule; // Avtomatik sana tanlash
  final int daysInterval; // Kunlar oralig'i
  final int startHour; // O'yin boshlanish vaqti
  final int endHour; // O'yin tugash vaqti

  LeagueSettings({
    this.isDoubleRound = false,
    this.isAutoSchedule = false,
    this.daysInterval = 1,
    this.startHour = 18,
    this.endHour = 22,
  });

  Map<String, dynamic> toJson() => {
        'isDoubleRound': isDoubleRound,
        'isAutoSchedule': isAutoSchedule,
        'daysInterval': daysInterval,
        'startHour': startHour,
        'endHour': endHour,
      };

  factory LeagueSettings.fromJson(Map<String, dynamic> json) {
    return LeagueSettings(
      isDoubleRound: json['isDoubleRound'] as bool? ?? false,
      isAutoSchedule: json['isAutoSchedule'] as bool? ?? false,
      daysInterval: json['daysInterval'] as int? ?? 1,
      startHour: json['startHour'] as int? ?? 18,
      endHour: json['endHour'] as int? ?? 22,
    );
  }
}

class TournamentModel {
  final String id;
  String name;
  List<TeamModel> teams;
  bool isDrawDone;
  List<MatchModel> matches;
  String? championId;
  TournamentType type;
  LeagueSettings? leagueSettings;

  TournamentModel({
    String? id,
    required this.name,
    required this.teams,
    this.isDrawDone = false,
    List<MatchModel>? matches,
    this.championId,
    this.type = TournamentType.knockout,
    this.leagueSettings,
  })  : id = id ?? uuid.v4(),
        matches = matches ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'teams': teams.map((t) => t.toJson()).toList(),
        'isDrawDone': isDrawDone,
        'matches': matches.map((m) => m.toJson()).toList(),
        'championId': championId,
        'type': type.index,
        'leagueSettings': leagueSettings?.toJson(),
      };

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    var teamsList = json['teams'] as List;
    List<TeamModel> teams =
        teamsList.map((i) => TeamModel.fromJson(i)).toList();
    var matchesList = json['matches'] as List;
    List<MatchModel> matches =
        matchesList.map((i) => MatchModel.fromJson(i)).toList();

    return TournamentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      teams: teams,
      isDrawDone: json['isDrawDone'] as bool? ?? false,
      matches: matches,
      championId: json['championId'] as String?,
      type: TournamentType.values[json['type'] as int? ?? 0],
      leagueSettings: json['leagueSettings'] != null
          ? LeagueSettings.fromJson(json['leagueSettings'])
          : null,
    );
  }
}
