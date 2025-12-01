import 'package:flutter/material.dart';

class PlayerProgressPage extends StatefulWidget {
  const PlayerProgressPage({super.key});

  @override
  State<PlayerProgressPage> createState() => _PlayerProgressPageState();
}

class _PlayerProgressPageState extends State<PlayerProgressPage> {
  int totalPoints = 68;
  int usedPoints = 0;
  int ovr = 83;

  Map<String, int> categoryPoints = {
    'Shooting': 0,
    'Passing': 0,
    'Dribbling': 0,
    'Attack Boost': 0,
    'Power & Speed': 0,
    'Physical': 0,
    'Defence': 0,
    'Goalkeeper 1': 0,
    'Goalkeeper 2': 0,
    'Goalkeeper 3': 0,
  };

  Map<String, int> stats = {
    'Attacking Awareness': 63,
    'Ball Control': 75,
    'Dribbling': 71,
    'Tight Possession': 80,
    'Low Pass': 83,
    'Lofted Pass': 79,
    'Finishing': 62,
    'Heading': 56,
    'Set Piece Taking': 74,
    'Curl': 75,
    'Defensive Awareness': 73,
    'Tackling': 73,
    'Aggression': 82,
    'Defensive Engagement': 80,
    'GK Awareness': 40,
    'GK Catching': 40,
    'GK Parrying': 40,
    'GK Reflex': 40,
    'GK Reach': 40,
    'Speed': 72,
    'Acceleration': 69,
    'Kicking Power': 79,
    'Jumping': 63,
    'Physical Contact': 71,
    'Balance': 77,
    'Stamina': 82,
  };

  Color _getColor(int value) {
    if (value < 70) return Colors.redAccent;
    if (value < 80) return Colors.orange;
    if (value < 90) return Colors.green;
    return Colors.greenAccent;
  }

  void _updateCategory(String category, bool increase) {
    setState(() {
      int current = categoryPoints[category]!;

      if (increase) {
        int cost = (current ~/ 4) + 1;
        if (usedPoints + cost <= totalPoints) {
          categoryPoints[category] = current + 1;
          usedPoints += cost;
          _applyStatChanges(category, 1);
        }
      } else {
        if (current > 0) {
          int cost = ((current - 1) ~/ 4) + 1;
          categoryPoints[category] = current - 1;
          usedPoints -= cost;
          if (usedPoints < 0) usedPoints = 0;
          _applyStatChanges(category, -1);
        }
      }

      // Statlar o‘zgarganidan keyin OVR qayta hisoblanadi
      _calculateOVR();
    });
  }

  void _applyStatChanges(String category, int delta) {
    switch (category) {
      case 'Shooting':
        _changeStats(['Finishing', 'Set Piece Taking', 'Curl'], delta);
        break;
      case 'Passing':
        _changeStats(['Low Pass', 'Lofted Pass'], delta);
        break;
      case 'Dribbling':
        _changeStats(['Dribbling', 'Ball Control', 'Tight Possession'], delta);
        break;
      case 'Attack Boost':
        _changeStats(['Attacking Awareness', 'Acceleration', 'Balance'], delta);
        break;
      case 'Power & Speed':
        _changeStats(['Kicking Power', 'Speed', 'Stamina'], delta);
        break;
      case 'Physical':
        _changeStats(['Heading', 'Jumping', 'Physical Contact'], delta);
        break;
      case 'Defence':
        _changeStats([
          'Defensive Awareness',
          'Tackling',
          'Aggression',
          'Defensive Engagement'
        ], delta);
        break;
      case 'Goalkeeper 1':
        _changeStats(['GK Awareness', 'Jumping'], delta);
        break;
      case 'Goalkeeper 2':
        _changeStats(['GK Parrying', 'GK Reach'], delta);
        break;
      case 'Goalkeeper 3':
        _changeStats(['GK Catching', 'GK Reflex'], delta);
        break;
    }
  }

  void _changeStats(List<String> affectedStats, int delta) {
    for (var s in affectedStats) {
      stats[s] = (stats[s]! + delta).clamp(40, 99);
    }
  }

  void _calculateOVR() {
    // Faqat Defence va GK statlari bo‘yicha hisoblaymiz
    List<String> defenseStats = [
      'Defensive Awareness',
      'Tackling',
      'Aggression',
      'Defensive Engagement',
      'GK Awareness',
      'GK Catching',
      'GK Parrying',
      'GK Reflex',
      'GK Reach'
    ];

    int total = 0;
    for (var stat in defenseStats) {
      total += stats[stat]!;
    }

    ovr = (total / defenseStats.length).round().clamp(65, 92);
  }

  void _resetProgress() {
    setState(() {
      usedPoints = 0;
      categoryPoints.updateAll((key, value) => 0);
      Map<String, int> initialStats = {
        'Attacking Awareness': 63,
        'Ball Control': 75,
        'Dribbling': 71,
        'Tight Possession': 80,
        'Low Pass': 83,
        'Lofted Pass': 79,
        'Finishing': 62,
        'Heading': 56,
        'Set Piece Taking': 74,
        'Curl': 75,
        'Defensive Awareness': 73,
        'Tackling': 73,
        'Aggression': 82,
        'Defensive Engagement': 80,
        'GK Awareness': 40,
        'GK Catching': 40,
        'GK Parrying': 40,
        'GK Reflex': 40,
        'GK Reach': 40,
        'Speed': 72,
        'Acceleration': 69,
        'Kicking Power': 79,
        'Jumping': 63,
        'Physical Contact': 71,
        'Balance': 77,
        'Stamina': 82,
      };
      stats.updateAll((key, value) => initialStats[key]!);
      _calculateOVR();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text("Player Progression",
            style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                "Points: ${totalPoints - usedPoints}/$totalPoints",
                style: const TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Text("Categories",
                  style: TextStyle(color: Colors.white, fontSize: 22)),
            ),
            ...categoryPoints.keys.map((key) {
              return ListTile(
                title: Text(key),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () => _updateCategory(key, false),
                        icon: const Icon(Icons.remove, color: Colors.redAccent)),
                    Text("${categoryPoints[key]}"),
                    IconButton(
                        onPressed: () => _updateCategory(key, true),
                        icon:
                            const Icon(Icons.add, color: Colors.greenAccent)),
                  ],
                ),
              );
            }),
            const Divider(),
            ListTile(
              title:
                  const Text("Reset Progress", style: TextStyle(color: Colors.redAccent)),
              onTap: _resetProgress,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              "OVR: $ovr",
              style: TextStyle(
                color: _getColor(ovr),
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: stats.keys.map((key) {
                  final value = stats[key]!;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(key),
                        Text(
                          "$value",
                          style: TextStyle(
                            color: _getColor(value),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
