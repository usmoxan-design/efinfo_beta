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
    required String type, // 'League' or 'Knockout'
    required bool includeCreator,
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
      teams: [], // Fix: required field
      type: type == 'League' ? TournamentType.league : TournamentType.knockout,
    );

    final List<String> players = [user.email!];
    if (includeCreator) {
      model.teams.add(TeamModel(
        id: "creator_${user.uid}",
        name: user.displayName ?? "Siz (Yaratuvchi)",
        color: const Color(0xFF0000FF), // Fix: pass Color object
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
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
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
              color: const Color(0xFF00FF00), // Fix: use Color object
            ));

            transaction.update(tourRef, {
              'players': players,
              'tournamentData': model.toJson(),
            });
          }
        }

        transaction.update(
            _firestore.collection('tournament_requests').doc(requestId), {
          'status': 'accepted',
        });
      });
    } else {
      await _firestore.collection('tournament_requests').doc(requestId).update({
        'status': 'declined',
      });
    }
  }

  User? get currentUser => _auth.currentUser;

  // Update TournamentData
  Future<void> updateTournamentData(
      String tournamentId, TournamentModel model) async {
    await _firestore.collection('online_tournaments').doc(tournamentId).update({
      'tournamentData': model.toJson(),
    });
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

        // Remove from teams. If it's the creator, we might need special handling if we want to allow removing self.
        // But usually, only creator can remove others.
        // If playerEmail is the creator's email, remove the team with id "creator_${creatorId}"
        // Otherwise, remove the team with id matching playerEmail
        final String creatorId = data['creatorId'];
        final String creatorEmail = data['players'].firstWhere(
            (email) => email != null && email.contains('@'),
            orElse: () =>
                ''); // Assuming creator is always the first player added

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
}
