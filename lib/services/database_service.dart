import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pes_models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database?> get database async {
    if (kIsWeb) return null; // sqflite does not support web
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pes_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE players(
            id TEXT PRIMARY KEY,
            name TEXT,
            club TEXT,
            nationality TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE player_details(
            id TEXT PRIMARY KEY,
            player_data TEXT,
            detail_data TEXT
          )
        ''');
      },
    );
  }

  Future<void> savePlayers(List<PesPlayer> players) async {
    final db = await database;
    if (db == null) return;

    final batch = db.batch();
    for (var player in players) {
      batch.insert(
        'players',
        {
          'id': player.id,
          'name': player.name,
          'club': player.club,
          'nationality': player.nationality,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<PesPlayer>> getPlayers() async {
    final db = await database;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps = await db.query('players');
    return List.generate(maps.length, (i) {
      return PesPlayer(
        id: maps[i]['id'],
        name: maps[i]['name'],
        club: maps[i]['club'],
        nationality: maps[i]['nationality'],
      );
    });
  }

  Future<void> savePlayerDetail(PesPlayerDetail detail) async {
    final db = await database;
    if (db == null) return;

    await db.insert(
      'player_details',
      {
        'id': detail.player.id,
        'player_data': jsonEncode({
          'id': detail.player.id,
          'name': detail.player.name,
          'club': detail.player.club,
          'nationality': detail.player.nationality,
        }),
        'detail_data': jsonEncode({
          'position': detail.position,
          'height': detail.height,
          'age': detail.age,
          'foot': detail.foot,
          'stats': detail.stats,
          'info': detail.info,
          'playingStyle': detail.playingStyle,
          'skills': detail.skills,
          'suggestedPoints': detail.suggestedPoints,
          'description': detail.description,
        }),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PesPlayerDetail?> getPlayerDetail(String id) async {
    final db = await database;
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      'player_details',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final playerData = jsonDecode(maps[0]['player_data']);
    final detailData = jsonDecode(maps[0]['detail_data']);

    final player = PesPlayer(
      id: playerData['id'],
      name: playerData['name'],
      club: playerData['club'],
      nationality: playerData['nationality'],
    );

    return PesPlayerDetail(
      player: player,
      position: detailData['position'],
      height: detailData['height'],
      age: detailData['age'],
      foot: detailData['foot'],
      stats: Map<String, String>.from(detailData['stats']),
      info: Map<String, String>.from(detailData['info']),
      playingStyle: detailData['playingStyle'],
      skills: List<String>.from(detailData['skills']),
      suggestedPoints: Map<String, int>.from(detailData['suggestedPoints']),
      description: detailData['description'],
    );
  }
}
