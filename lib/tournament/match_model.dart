import 'package:efinfo_beta/tournament/team_model.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class MatchModel {
  final String id;
  TeamModel? teamA;
  TeamModel? teamB;
  int scoreA;
  int scoreB;
  String? winnerId;
  final int round; // Turnir bosqichi: 1, 2, 3, ... (Final)
  int? nextMatchId; // Keyingi raunddagi qaysi matchga o'tishini bildiradi
  int? nextTeamSlot; // Keyingi matchda A yoki B (0 = A, 1 = B)
  bool isPlayed;
  DateTime? date;

  MatchModel({
    String? id,
    this.teamA,
    this.teamB,
    this.scoreA = 0,
    this.scoreB = 0,
    this.winnerId,
    required this.round,
    this.nextMatchId,
    this.nextTeamSlot,
    this.isPlayed = false,
    this.date,
  }) : id = id ?? uuid.v4();

  // G'olibni aniqlash
  void determineWinner() {
    if (teamA == null || teamB == null) {
      winnerId = null;
      return;
    }
    if (scoreA > scoreB) {
      winnerId = teamA!.id;
    } else if (scoreB > scoreA) {
      winnerId = teamB!.id;
    } else {
      winnerId = null; // Durang/Qayta o'yin kerak
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'teamA': teamA?.toJson(),
        'teamB': teamB?.toJson(),
        'scoreA': scoreA,
        'scoreB': scoreB,
        'winnerId': winnerId,
        'round': round,
        'nextMatchId': nextMatchId,
        'nextTeamSlot': nextTeamSlot,
        'isPlayed': isPlayed,
        'date': date?.toIso8601String(),
      };

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      teamA: json['teamA'] != null ? TeamModel.fromJson(json['teamA']) : null,
      teamB: json['teamB'] != null ? TeamModel.fromJson(json['teamB']) : null,
      scoreA: json['scoreA'] as int,
      scoreB: json['scoreB'] as int,
      winnerId: json['winnerId'] as String?,
      round: json['round'] as int,
      nextMatchId: json['nextMatchId'] as int?,
      nextTeamSlot: json['nextTeamSlot'] as int?,
      isPlayed: json['isPlayed'] as bool? ?? false,
      date:
          json['date'] != null ? DateTime.parse(json['date'] as String) : null,
    );
  }
}
