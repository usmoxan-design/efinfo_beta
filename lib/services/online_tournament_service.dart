import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:efinfo_beta/tournament/tournament_model.dart';
import 'package:efinfo_beta/tournament/team_model.dart';
import 'package:flutter/material.dart';

class OnlineTournamentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create Online Tournament
  Future<void> createTournament({
    required String name,
    required String type,
    required bool includeCreator,
    bool isDoubleRound = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw "Tizimga kirmagansiz!";

    // Check coins
    final userDoc =
        await _firestore.collection('chat_users').doc(user.uid).get();
    final int coins = userDoc.data()?['coins'] ?? 0;
    if (coins < 100) throw "Mablag' yetarli emas! 100 coin kerak.";

    // Deduct coins
    await _firestore.collection('chat_users').doc(user.uid).update({
      'coins': FieldValue.increment(-100),
    });

    // Initialize local TournamentModel structure
    final tournamentId = _firestore.collection('online_tournaments').doc().id;
    final model = TournamentModel(
      id: tournamentId,
      name: name,
      teams: [],
      type: type == 'League' ? TournamentType.league : TournamentType.knockout,
      creatorId: user.uid,
      isOnline: true,
      leagueSettings: type == 'League'
          ? LeagueSettings(isDoubleRound: isDoubleRound)
          : null,
      startDate: DateTime.now(),
    );

    final List<String> players = [user.email!];
    if (includeCreator) {
      model.teams.add(TeamModel(
        id: "creator_${user.uid}",
        name: user.displayName ?? "Siz (Yaratuvchi)",
        color: const Color(0xFF0000FF),
      ));
    }

    // Create tournament document
    await _firestore.collection('online_tournaments').doc(tournamentId).set({
      'id': tournamentId,
      'name': name,
      'creatorId': user.uid,
      'creatorName': user.displayName ?? 'Noma\'lum',
      'type': type,
      'includeCreator': includeCreator,
      'players': players,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'startDate': FieldValue.serverTimestamp(),
      'isDoubleRound': isDoubleRound,
      'tournamentData': model.toJson(),
    });
  }

  // Get online tournaments where user is a player
  Stream<List<Map<String, dynamic>>> getMyTournaments() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('online_tournaments')
        .where('players', arrayContains: user.email)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => doc.data())
            .where((data) =>
                data['status'] != 'deleted' && data['status'] != 'completed')
            .toList());
  }

  // Send request to join tournament
  Future<void> sendJoinRequest(
      String tournamentId, String tournamentName, String toEmail) async {
    final user = _auth.currentUser;
    if (user == null) throw "Tizimga kirmagansiz!";

    // Check if user exists
    final targetUserSnap = await _firestore
        .collection('chat_users')
        .where('email', isEqualTo: toEmail)
        .get();
    if (targetUserSnap.docs.isEmpty)
      throw "Ushbu email bilan foydalanuvchi topilmadi!";

    final requestId = "${tournamentId}_${toEmail.replaceAll('@', '_')}";

    await _firestore.collection('tournament_requests').doc(requestId).set({
      'id': requestId,
      'tournamentId': tournamentId,
      'tournamentName': tournamentName,
      'fromId': user.uid,
      'fromName': user.displayName ?? 'Noma\'lum',
      'toEmail': toEmail,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get my invitations
  Stream<List<Map<String, dynamic>>> getMyRequests() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('tournament_requests')
        .where('toEmail', isEqualTo: user.email)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  // Get count of pending requests for badge
  Stream<int> getRequestsCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('tournament_requests')
        .where('toEmail', isEqualTo: user.email)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // Handle request (Accept/Decline)
  Future<void> handleRequest(String requestId, bool accept) async {
    final requestSnap =
        await _firestore.collection('tournament_requests').doc(requestId).get();
    if (!requestSnap.exists) return;

    final requestData = requestSnap.data()!;
    final tournamentId = requestData['tournamentId'];
    final userEmail = requestData['toEmail'];
    final userName = requestData['toEmail'].split('@').first;

    if (accept) {
      final targetUserSnap = await _firestore
          .collection('chat_users')
          .where('email', isEqualTo: userEmail)
          .get();
      final realName = targetUserSnap.docs.isNotEmpty
          ? targetUserSnap.docs.first.data()['name']
          : userName;

      await _firestore.runTransaction((transaction) async {
        final tourRef =
            _firestore.collection('online_tournaments').doc(tournamentId);
        final tourSnap = await transaction.get(tourRef);

        if (tourSnap.exists) {
          final data = tourSnap.data()!;
          final List players = List.from(data['players'] ?? []);
          if (!players.contains(userEmail)) {
            players.add(userEmail);

            final modelMap = Map<String, dynamic>.from(data['tournamentData']);
            final model = TournamentModel.fromJson(modelMap);

            model.teams.add(TeamModel(
              id: userEmail,
              name: realName,
              color: const Color(0xFF00FF00),
            ));

            transaction.update(tourRef, {
              'players': players,
              'tournamentData': model.toJson(),
            });
          }
        }

        // Delete request instead of updating status
        transaction.delete(
            _firestore.collection('tournament_requests').doc(requestId));
      });
    } else {
      // Delete request if declined
      await _firestore
          .collection('tournament_requests')
          .doc(requestId)
          .delete();
    }
  }

  User? get currentUser => _auth.currentUser;

  // Update TournamentData
  Future<void> updateTournamentData(
      String tournamentId, TournamentModel model) async {
    final Map<String, dynamic> updateData = {
      'tournamentData': model.toJson(),
    };
    if (model.isCompleted && model.endDate == null) {
      model.endDate = DateTime.now();
      updateData['tournamentData'] = model.toJson();
      updateData['endDate'] = FieldValue.serverTimestamp();
      updateData['status'] = 'completed';
    }
    await _firestore
        .collection('online_tournaments')
        .doc(tournamentId)
        .update(updateData);
  }

  // Rename Tournament
  Future<void> renameTournament(String tournamentId, String newName) async {
    await _firestore.collection('online_tournaments').doc(tournamentId).update({
      'name': newName,
    });
  }

  // Remove Player from Tournament
  Future<void> removePlayer(String tournamentId, String playerEmail) async {
    await _firestore.runTransaction((transaction) async {
      final tourRef =
          _firestore.collection('online_tournaments').doc(tournamentId);
      final tourSnap = await transaction.get(tourRef);

      if (tourSnap.exists) {
        final data = tourSnap.data()!;
        final List players = List.from(data['players'] ?? []);
        players.remove(playerEmail);

        final modelMap = Map<String, dynamic>.from(data['tournamentData']);
        final model = TournamentModel.fromJson(modelMap);

        final String creatorId = data['creatorId'];
        final String creatorEmail = data['players'].firstWhere(
            (email) => email != null && email.contains('@'),
            orElse: () => '');

        model.teams.removeWhere((t) {
          if (playerEmail == creatorEmail && t.id == "creator_$creatorId") {
            return true;
          }
          return t.id == playerEmail;
        });

        transaction.update(tourRef, {
          'players': players,
          'tournamentData': model.toJson(),
        });
      }
    });
  }

  // Get requests for a specific tournament (for creator)
  Stream<List<Map<String, dynamic>>> getTournamentRequests(
      String tournamentId) {
    return _firestore
        .collection('tournament_requests')
        .where('tournamentId', isEqualTo: tournamentId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  // Get specific tournament data
  Stream<Map<String, dynamic>> getTournament(String tournamentId) {
    return _firestore
        .collection('online_tournaments')
        .doc(tournamentId)
        .snapshots()
        .map((snap) => snap.data() ?? {});
  }

  // Alias for getTournament
  Stream<Map<String, dynamic>> getTournamentStream(String tournamentId) {
    return getTournament(tournamentId);
  }

  // Check if current user is admin
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await _firestore.collection('chat_users').doc(user.uid).get();
    return doc.data()?['role'] == 'admin' || doc.data()?['isAdmin'] == true;
  }

  // Delete online tournament
  Future<void> deleteTournament(String tournamentId) async {
    try {
      // First try to delete associated requests (optional, ignore errors)
      try {
        final requests = await _firestore
            .collection('tournament_requests')
            .where('tournamentId', isEqualTo: tournamentId)
            .get();
        for (var doc in requests.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint("Request deletion failed during tournament delete: $e");
      }

      // Try to hard delete the tournament
      await _firestore
          .collection('online_tournaments')
          .doc(tournamentId)
          .delete();
    } catch (e) {
      // If hard delete fails (usually permission denied for non-creators),
      // we perform a "soft delete" by updating the status.
      // This hide it for everyone since getMyTournaments filters by status.
      debugPrint("Hard delete failed, performing soft delete: $e");
      await _firestore
          .collection('online_tournaments')
          .doc(tournamentId)
          .update({
        'status': 'deleted',
      });
    }
  }

  // Join tournament directly (via code/link)
  Future<void> joinTournament(String tournamentId) async {
    final user = _auth.currentUser;
    if (user == null) throw "Tizimga kirmagansiz!";

    // Prepare user details
    final userDoc =
        await _firestore.collection('chat_users').doc(user.uid).get();
    final String userName =
        userDoc.data()?['name'] ?? user.displayName ?? "Foydalanuvchi";
    final String userEmail = user.email!;

    await _firestore.runTransaction((transaction) async {
      final tourRef =
          _firestore.collection('online_tournaments').doc(tournamentId);
      final tourSnap = await transaction.get(tourRef);

      if (!tourSnap.exists) {
        throw "Turnir topilmadi! Kod noto'g'ri bo'lishi mumkin.";
      }

      final data = tourSnap.data()!;

      // Validation
      if (data['status'] == 'completed' || data['status'] == 'deleted') {
        throw "Bu turnir allaqachon tugagan yoki o'chirilgan.";
      }

      // Check if already joined
      final List players = List.from(data['players'] ?? []);
      if (players.contains(userEmail)) {
        throw "Siz allaqachon ushbu turnirga qo'shilgansiz!";
      }

      // Add user
      players.add(userEmail);

      // Update model teams
      final modelMap = Map<String, dynamic>.from(data['tournamentData']);
      final model = TournamentModel.fromJson(modelMap);

      // Check if draw is already done (optional: usually we prevent joining if draw is done)
      if (model.isDrawDone) {
        throw "Turnir allaqachon boshlangan (qura tashlangan)!";
      }

      String teamId = userEmail;
      // Special check if creator is re-joining
      if (data['creatorId'] == user.uid) {
        teamId = "creator_${user.uid}";
      }

      model.teams.add(TeamModel(
        id: teamId,
        name: userName,
        color: const Color(0xFF00FF00), // Default color
      ));

      transaction.update(tourRef, {
        'players': players,
        'tournamentData': model.toJson(),
      });
    });
  }
}
