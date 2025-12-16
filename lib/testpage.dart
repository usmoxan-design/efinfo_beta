import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PlayerProgressPage extends StatefulWidget {
  const PlayerProgressPage({super.key});

  @override
  State<PlayerProgressPage> createState() => _PlayerProgressPageState();
}

class _PlayerProgressPageState extends State<PlayerProgressPage> {
  int totalPoints = 52;
  int usedPoints = 0;
  int ovr = 84;
  String selectedPosition = 'RB'; // Default position

  // Har bir pozitsiya uchun muhim statlarning vaznlari (taxminiy eFootball formulasi)
  final Map<String, Map<String, double>> positionWeights = {
    'CF': {
      'Attacking Awareness': 0.15,
      'Finishing': 0.15,
      'Kicking Power': 0.10,
      'Heading': 0.10,
      'Ball Control': 0.05,
      'Dribbling': 0.05,
      'Speed': 0.10,
      'Acceleration': 0.10,
      'Balance': 0.05,
      'Physical Contact': 0.10,
      'Jumping': 0.05,
    },
    'LWF/RWF': {
      'Dribbling': 0.15,
      'Ball Control': 0.10,
      'Speed': 0.15,
      'Acceleration': 0.15,
      'Lofted Pass': 0.10,
      'Finishing': 0.10,
      'Attacking Awareness': 0.05,
      'Balance': 0.10,
      'Stamina': 0.05,
      'Curl': 0.05,
    },
    'SS': {
      'Ball Control': 0.10,
      'Dribbling': 0.10,
      'Low Pass': 0.10,
      'Finishing': 0.10,
      'Attacking Awareness': 0.15,
      'Speed': 0.10,
      'Acceleration': 0.10,
      'Balance': 0.10,
      'Curl': 0.05,
      'Kicking Power': 0.05,
    },
    'AMF': {
      'Low Pass': 0.15,
      'Lofted Pass': 0.10,
      'Ball Control': 0.15,
      'Dribbling': 0.10,
      'Tight Possession': 0.10,
      'Finishing': 0.05,
      'Attacking Awareness': 0.05,
      'Balance': 0.10,
      'Stamina': 0.05,
      'Curl': 0.05,
    },
    'CMF': {
      'Low Pass': 0.15,
      'Lofted Pass': 0.15,
      'Ball Control': 0.10,
      'Stamina': 0.15,
      'Defensive Awareness': 0.05,
      'Defensive Engagement': 0.05,
      'Tackling': 0.05,
      'Aggression': 0.05,
      'Speed': 0.05,
      'Balance': 0.05,
      'Physical Contact': 0.05,
    },
    'DMF': {
      'Defensive Awareness': 0.15,
      'Tackling': 0.15,
      'Aggression': 0.10,
      'Defensive Engagement': 0.10,
      'Low Pass': 0.10,
      'Lofted Pass': 0.10,
      'Stamina': 0.10,
      'Physical Contact': 0.10,
      'Ball Control': 0.05,
      'Heading': 0.05,
    },
    'LB/RB': {
      'Speed': 0.15,
      'Acceleration': 0.15,
      'Stamina': 0.15,
      'Lofted Pass': 0.15, // Krosslar uchun muhim
      'Low Pass': 0.05,
      'Defensive Awareness': 0.10,
      'Ball Control': 0.05,
      'Dribbling': 0.05,
      'Tackling': 0.05,
      'Aggression': 0.05,
      'Balance': 0.05,
      'Curl': 0.05, // Trent kabi o'yinchilar uchun
      'Set Piece Taking': 0.05,
    },
    'CB': {
      'Defensive Awareness': 0.20,
      'Tackling': 0.20,
      'Aggression': 0.15,
      'Defensive Engagement': 0.10,
      'Heading': 0.10,
      'Physical Contact': 0.10,
      'Jumping': 0.10,
      'Speed': 0.05,
    },
    'GK': {
      'GK Awareness': 0.25,
      'GK Reflex': 0.25,
      'GK Parrying': 0.20,
      'GK Catching': 0.15,
      'GK Reach': 0.15,
    },
  };

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
    'Attacking Awareness': 66,
    'Ball Control': 77,
    'Dribbling': 72,
    'Tight Possession': 75,
    'Low Pass': 81,
    'Lofted Pass': 84,
    'Finishing': 57,
    'Heading': 50,
    'Set Piece Taking': 80,
    'Curl': 86,
    'Defensive Awareness': 73,
    'Tackling': 77,
    'Aggression': 75,
    'Defensive Engagement': 79,
    'GK Awareness': 40,
    'GK Catching': 40,
    'GK Parrying': 40,
    'GK Reflex': 40,
    'GK Reach': 40,
    'Speed': 76,
    'Acceleration': 71,
    'Kicking Power': 78,
    'Jumping': 69,
    'Physical Contact': 64,
    'Balance': 68,
    'Stamina': 84,
  };

  Color _getColor(int value) {
    if (value < 70) return Colors.redAccent;
    if (value < 80) return Colors.orange;
    if (value < 90) return Colors.lightGreen;
    return AppColors.accent; // 90+ uchun yorqin yashil
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
    if (stats.isEmpty) return;

    // Tanlangan pozitsiya uchun vaznlarni olish
    String posKey = selectedPosition;
    if (selectedPosition == 'RB' || selectedPosition == 'LB') posKey = 'LB/RB';
    if (selectedPosition == 'LWF' || selectedPosition == 'RWF') {
      posKey = 'LWF/RWF';
    }

    Map<String, double> weights = positionWeights[posKey] ?? {};

    double totalWeightedScore = 0.0;
    double totalWeights = 0.0;

    // Vaznli yig'indini hisoblash
    weights.forEach((statName, weight) {
      if (stats.containsKey(statName)) {
        totalWeightedScore += stats[statName]! * weight;
        totalWeights += weight;
      }
    });

    if (totalWeights == 0) {
      ovr = 0;
      return;
    }

    // Natijani normallashtirish va eFootball OVR shkalasiga moslash
    // eFootball da OVR odatda vaznli o'rtachadan biroz balandroq bo'ladi
    double weightedAverage = totalWeightedScore / totalWeights;

    // Formula to'g'rilandi: Progressiv o'sish.
    // Statlar qancha yuqori bo'lsa, OVR shuncha tez oshadi (eFootball kabi).
    // Agar weightedAverage 70 bo'lsa -> 70 + 0 + 6 = 76
    // Agar weightedAverage 80 bo'lsa -> 80 + 4 + 6 = 90
    // Agar weightedAverage 85 bo'lsa -> 85 + 6 + 6 = 97

    double boost = 0;
    if (weightedAverage > 70) {
      boost = (weightedAverage - 70) *
          0.5; // Har bir ball 70 dan oshganda 1.5 baravar kuchli
    }

    ovr = (weightedAverage + boost + 4).round();
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text("Training Simulator",
            style: TextStyle(color: Colors.white)),
        actions: [
          // Pozitsiya Tanlash Dropdown
          DropdownButton<String>(
            value: selectedPosition,
            dropdownColor: AppColors.background,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.accent),
            items: [
              'CF',
              'SS',
              'LWF',
              'RWF',
              'AMF',
              'CMF',
              'DMF',
              'LB',
              'RB',
              'CB',
              'GK'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedPosition = newValue!;
                _calculateOVR();
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Center(
              child: Text(
                "Pts: ${totalPoints - usedPoints}",
                style: const TextStyle(
                    color: AppColors.accent, fontWeight: FontWeight.bold),
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
              decoration: BoxDecoration(color: AppColors.background),
              child: Text("Categories",
                  style: TextStyle(color: Colors.white, fontSize: 22)),
            ),
            ...categoryPoints.keys.map((key) {
              return ListTile(
                title: Text(key, style: const TextStyle(color: Colors.white70)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () => _updateCategory(key, false),
                        icon: const Icon(Icons.remove, color: Colors.orange)),
                    Text("${categoryPoints[key]}",
                        style: const TextStyle(color: Colors.white)),
                    IconButton(
                        onPressed: () => _updateCategory(key, true),
                        icon: const Icon(Icons.add, color: AppColors.accent)),
                  ],
                ),
              );
            }),
            const Divider(),
            ListTile(
              title: const Text("Reset Progress",
                  style: TextStyle(color: Colors.redAccent)),
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
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(key, style: const TextStyle(color: Colors.white)),
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
