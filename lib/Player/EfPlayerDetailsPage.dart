import 'dart:convert';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EfPlayerDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? playerData; // Optional, can be passed from list

  const EfPlayerDetailsPage({super.key, this.playerData});

  @override
  State<EfPlayerDetailsPage> createState() => _EfPlayerDetailsPageState();
}

class _EfPlayerDetailsPageState extends State<EfPlayerDetailsPage> {
  Map<String, dynamic>? playerData;
  bool isLoading = true;

  // Training Logic State
  int totalTrainingPoints = 60; // Default pool
  int usedPoints = 0;
  int currentOvr = 0;

  // Dynamic stats
  Map<String, int> stats = {};

  // Base stats (to reset or calculate delta)
  Map<String, int> baseStats = {};

  // Category Points
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

  // Har bir pozitsiya uchun muhim statlarning vaznlari (taxminiy eFootball formulasi)
  final Map<String, Map<String, double>> positionWeights = {
    'CF': {
      'Offensive Awareness': 0.15,
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
      'Offensive Awareness': 0.05,
      'Balance': 0.10,
      'Stamina': 0.05,
      'Curl': 0.05,
    },
    'SS': {
      'Ball Control': 0.10,
      'Dribbling': 0.10,
      'Low Pass': 0.10,
      'Finishing': 0.10,
      'Offensive Awareness': 0.15,
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
      'Offensive Awareness': 0.05,
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
      'Lofted Pass': 0.15,
      'Low Pass': 0.05,
      'Defensive Awareness': 0.10,
      'Ball Control': 0.05,
      'Dribbling': 0.05,
      'Tackling': 0.05,
      'Aggression': 0.05,
      'Balance': 0.05,
      'Curl': 0.05,
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
      'GK Reflexes': 0.25,
      'GK Parrying': 0.20,
      'GK Catching': 0.15,
      'GK Reach': 0.15,
    },
  };

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (widget.playerData != null) {
      _initData(widget.playerData!);
    } else {
      _loadPlayerData();
    }
  }

  void _initData(Map<String, dynamic> data) {
    playerData = data;
    isLoading = false;
    currentOvr = data['rating'] ?? 0;
    // Load progression points from data
    if (data['progressionPoints'] != null) {
      totalTrainingPoints = data['progressionPoints'];
    } else {
      // Fallback logic
      int level = (data['maxLevel'] ?? 1) as int;
      totalTrainingPoints = (level - 1) * 2;
    }
    if (totalTrainingPoints < 0) totalTrainingPoints = 0;

    // Initialize stats
    if (data['stats'] != null) {
      final rawStats = data['stats'] as Map<String, dynamic>;
      rawStats.forEach((key, value) {
        if (value is num) {
          stats[key] = value.toInt();
          baseStats[key] = value.toInt();
        }
      });
    }
  }

  Future<void> _loadPlayerData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/mock_player.json');
      final data = await json.decode(response);
      Map<String, dynamic> targetPlayer;

      if (data is List) {
        targetPlayer = data[0]; // Load first if list
      } else {
        targetPlayer = data;
      }

      setState(() {
        _initData(targetPlayer);
      });
    } catch (e) {
      debugPrint("Error loading player data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // --- Training Logic Methods ---

  void _updateCategory(String category, bool increase) {
    setState(() {
      int current = categoryPoints[category]!;

      if (increase) {
        int cost = (current ~/ 4) + 1;
        if (usedPoints + cost <= totalTrainingPoints) {
          categoryPoints[category] = current + 1;
          usedPoints += cost;
          _applyStatChanges(category, 1);
        }
      } else {
        if (current > 0) {
          int refund = ((current - 1) ~/ 4) + 1;
          categoryPoints[category] = current - 1;
          usedPoints -= refund;
          if (usedPoints < 0) usedPoints = 0;
          _applyStatChanges(category, -1);
        }
      }

      // Recalculate OVR properly
      _calculateOVR();
    });
  }

  void _calculateOVR() {
    if (stats.isEmpty || playerData == null) return;

    // Normalize position key
    String pos = playerData!['position'];
    String posKey = pos;
    if (pos == 'RB' || pos == 'LB') posKey = 'LB/RB';
    if (pos == 'LWF' || pos == 'RWF') posKey = 'LWF/RWF';
    // Handle others if needed, using general mapping if key missing

    Map<String, double> weights = positionWeights[posKey] ?? {};
    if (weights.isEmpty) {
      // Fallback for simple boost calculation if weights unknown
      _calculateSimpleOvrBoost();
      return;
    }

    double totalWeightedScore = 0.0;
    double totalWeights = 0.0;

    weights.forEach((statName, weight) {
      if (stats.containsKey(statName)) {
        totalWeightedScore += stats[statName]! * weight;
        totalWeights += weight;
      }
    });

    if (totalWeights == 0) return;

    // Normalizing logic similar to PlayerProgressPage
    double weightedAverage = totalWeightedScore / totalWeights;
    double boost = 0;
    if (weightedAverage > 70) {
      boost = (weightedAverage - 70) * 0.5;
    }

    // Adjusting base offset to match card rating roughly
    setState(() {
      currentOvr = (weightedAverage + boost + 6).round(); // +6 heuristic tuning
    });
  }

  void _calculateSimpleOvrBoost() {
    // rudimentary boost logic for visual feedback
    // simplified: every X stat points total gain adds to OVR
    int totalStatGain = 0;
    stats.forEach((k, v) {
      if (baseStats.containsKey(k)) {
        totalStatGain += (v - baseStats[k]!);
      }
    });

    if (playerData != null) {
      int baseRating = playerData!['rating'];
      // Approximate: 6 stat points ~ 1 OVR (very rough estimate)
      int boost = (totalStatGain / 15).floor();
      currentOvr = baseRating + boost;
    }
  }

  Color _getColor(int value) {
    if (value < 70) return Colors.redAccent;
    if (value < 80) return Colors.orange;
    if (value < 90) return Colors.lightGreen;
    return AppColors.accent; // 90+
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
        _changeStats(['Offensive Awareness', 'Acceleration', 'Balance'],
            delta); // Mapped keys
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
        _changeStats(['GK Catching', 'GK Reflexes'], delta); // Mapped
        break;
    }
  }

  void _changeStats(List<String> affectedStats, int delta) {
    for (var s in affectedStats) {
      if (stats.containsKey(s)) {
        // eFootball logic: +2 stats every 1 point usually, but let's do +1 for simulator simplicity
        // Or if following the game strictly:
        // Levels 1-4 cost 1 pt (gives +1 stat per point allocated to category, usually affects multiple stats by +1)
        // Here we just add delta to the stat value directly.
        stats[s] = (stats[s]! + delta).clamp(40, 99); // Cap at 99
      }
    }
  }

  void _resetProgress() {
    setState(() {
      usedPoints = 0;
      categoryPoints.updateAll((key, value) => 0);
      stats = Map.from(baseStats);
      currentOvr = playerData!['rating'];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (playerData == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
            child: Text("Ma'lumot topilmadi",
                style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "${playerData!['position']}($currentOvr) ${playerData!['maxLevel']}/${playerData!['maxLevel']}",
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Text("Pts: ${totalTrainingPoints - usedPoints}",
                  style: const TextStyle(
                      color: AppColors.accent, fontWeight: FontWeight.bold)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_suggest_outlined),
            tooltip: "Training",
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: AppColors.surface,
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.background),
              child: Center(
                  child: Text("Training",
                      style: TextStyle(color: Colors.white, fontSize: 24))),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...categoryPoints.keys.map((key) {
                    // Quick check if this category is relevant for player position (optional optimization)
                    return ListTile(
                      title: Text(key,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () => _updateCategory(key, false),
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.orange)),
                          SizedBox(
                            width: 30,
                            child: Text("${categoryPoints[key]}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                              onPressed: () => _updateCategory(key, true),
                              icon: const Icon(Icons.add_circle_outline,
                                  color: AppColors.accent)),
                        ],
                      ),
                    );
                  }),
                  const Divider(color: Colors.white24),
                  ListTile(
                    leading:
                        const Icon(Icons.restart_alt, color: Colors.redAccent),
                    title: const Text("Reset",
                        style: TextStyle(color: Colors.redAccent)),
                    onTap: _resetProgress,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(playerData!),
            _buildProgressionBar(playerData!),
            _buildStatsGrid(stats), // Passing dynamic stats
            _buildPlayerModel(playerData!['playerModel']),
            _buildSkills(playerData!['skills']),
            // _buildPositionRatings(playerData!['positionRatings']), // Commented out as requested
            _buildPlayerInfo(playerData!),
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(playerData!),
    );
  }

  Widget _buildHeader(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF321045), // Purple gradient start approximation
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF321045),
            Color(0xFF5A1E75),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['cardTheme'] ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            children: [
              // Card Image Placeholder
              Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(data['images']?['card'] ??
                        'assets/images/messi_art.jpg'),
                    fit: BoxFit.cover,
                  ),
                  color: Colors.black26,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.black54,
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        data['name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Hexagon Chart Placeholder
              Expanded(
                child: SizedBox(
                    height: 160,
                    child: CustomPaint(
                      painter: HexagonPainter(),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(data['name'],
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                  "${data['age']}Y/O ${data['height']}CM ${data['weight']}KG ${data['foot']}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              Text(data['playstyle'],
                  style:
                      const TextStyle(color: AppColors.accent, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionBar(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.background,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text("Progression ${data['maxLevel']} / ${data['maxLevel']}",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text("MaxOut",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
          // Toggle buttons placeholder
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.grid_view, color: Colors.black),
          )
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, int> stats) {
    // We'll display specific ones relevant to stats
    final importantStats = [
      "Offensive Awareness",
      "Offensive Awareness",
      "Ball Control",
      "Ball Control",
      "Dribbling",
      "Dribbling",
      "Tight Possession",
      "Tight Possession",
      "Low Pass",
      "Low Pass",
      "Lofted Pass",
      "Lofted Pass",
      "Finishing",
      "Finishing",
      "Heading",
      "Heading",
      "Set Piece Taking",
      "Set Piece Taking",
      "Curl",
      "Curl",
      "Stamina",
      "Stamina",
      "Defensive Awareness",
      "Defensive Awareness",
      "Tackling",
      "Tackling",
      "Aggression",
      "Aggression",
      "Defensive Engagement",
      "Defensive Engagement",
      "Speed",
      "Speed",
      "Acceleration",
      "Acceleration",
      "Kicking Power",
      "Kicking Power",
      "Jumping",
      "Jumping",
      "Physical Contact",
      "Physical Contact",
      "Balance",
      "Balance",
      "GK Awareness",
      "GK Awareness",
      "GK Catching",
      "GK Catching",
      "GK Parrying",
      "GK Parrying",
      "GK Reflexes",
      "GK Reflexes",
      "GK Reach",
      "GK Reach",
    ];

    List<Widget> rows = [];
    for (int i = 0; i < importantStats.length; i += 4) {
      if (i + 3 >= importantStats.length) break;
      String label1 = importantStats[i];
      String key1 = importantStats[i + 1];
      String label2 = importantStats[i + 2];
      String key2 = importantStats[i + 3];

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(child: _buildStatItem(label1, stats[key1] ?? 40)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatItem(label2, stats[key2] ?? 40)),
            ],
          ),
        ),
      );
    }

    // Additional generic stats (from playerData usually, not dynamic integers in this mock setup, but for completeness)
    rows.add(const Divider(color: Colors.white10));
    rows.add(_buildGenericStatRow(
        "Weak Foot Usage",
        playerData!['stats']['Weak Foot Usage'],
        "Weak Foot Accuracy",
        playerData!['stats']['Weak Foot Accuracy']));
    rows.add(_buildGenericStatRow(
        "Conditioning",
        playerData!['stats']['Conditioning'],
        "Injury Resistance",
        playerData!['stats']['Injury Resistance']));

    return Column(children: rows);
  }

  Widget _buildStatItem(String label, int value) {
    // Color bg = Colors.grey;
    // if (value >= 90)
    //   bg = const Color(0xFF00ADB5); // Blue
    // else if (value >= 80)
    //   bg = const Color(0xFF86EFAC); // Green
    // else if (value >= 70)
    //   bg = const Color(0xFFEAB308); // Yellow
    // else
    //   bg = const Color(0xFFEF4444); // Red

    // Check increase from base to show small indicator
    int base = baseStats[label] ?? value;
    int diff = value - base;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            child: Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 13))),
        Row(
          children: [
            if (diff > 0)
              Text("+$diff ",
                  style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            Container(
              width: 35,
              height: 25,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _getColor(value), // Use dynamic color logic
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(value.toString(),
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildGenericStatRow(String l1, String? v1, String l2, String? v2) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l1, style: const TextStyle(color: Colors.white70)),
                Text(v1 ?? "-", style: TextStyle(color: _getValueColor(v1))),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l2, style: const TextStyle(color: Colors.white70)),
                Text(v2 ?? "-", style: TextStyle(color: _getValueColor(v2))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getValueColor(String? val) {
    if (val == "High" || val == "Unwavering") return AppColors.accent;
    if (val == "Medium") return Colors.amber;
    return Colors.white;
  }

  Widget _buildPlayerModel(Map<String, dynamic> model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text("Player Model",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        _buildModelRow(
            "Leg Coverage", model['legCoverage'], model['legCoverageTop']),
        _buildModelRow("Leg Length Based Height", model['legLengthBasedHeight'],
            model['legLengthBasedHeightTop']),
        _buildModelRow(
            "Arm Coverage", model['armCoverage'], model['armCoverageTop']),
        _buildModelRow("Torso Collision", model['torsoCollision'],
            model['torsoCollisionTop']),
        _buildModelRow("Jumping Height", model['jumpingHeight'],
            model['jumpingHeightTop']),
      ],
    );
  }

  Widget _buildModelRow(String label, dynamic val, dynamic top) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Row(
            children: [
              Text(val?.toString() ?? "-",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Text("Top ${top?.toString() ?? "-"}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSkills(List<dynamic> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text("Player Skills",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(s.toString(),
                          style: const TextStyle(color: Colors.white70)),
                    ))
                .toList(),
          ),
        )
      ],
    );
  }

  /* // Commented out as requested
  Widget _buildPositionRatings(Map<String, dynamic> positions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text("Ratings For All Positions",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        Container(
          height: 300,
          margin: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              // Row 1
              _buildPosBox("LWF", positions['LWF'], Colors.lightGreen),
              _buildCenterSplitBox(
                  "CF", positions['CF'], "SS", positions['SS']),
              _buildPosBox("RWF", positions['RWF'], Colors.teal),

              // Row 2
              _buildPosBox("LMF", positions['LMF'], const Color(0xFF374151)),
              _buildCenterSplitBox(
                  "AMF", positions['AMF'], "CMF", positions['CMF'],
                  isAmfHighlight: true),
              _buildPosBox(
                  "RMF", positions['RMF'], Colors.lightGreenAccent.shade700),

              // Row 3
              _buildPosBox("LB", positions['LB'], const Color(0xFF374151)),
              _buildCenterSplitBox(
                  "DMF", positions['DMF'], "CB", positions['CB']),
              _buildPosBox("RB", positions['RB'], const Color(0xFF374151)),
            ],
          ),
        ),
        // GK separated usually
        Center(
            child: _buildPosBox("GK", positions['GK'], const Color(0xFF374151),
                width: 100)),
      ],
    );
  }
  */

  Widget _buildPosBox(String pos, dynamic val, Color color, {double? width}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(pos,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          Text(val?.toString() ?? "-",
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  // Custom widget to mimic the dense detailed grid in screenshot
  Widget _buildCenterSplitBox(String p1, dynamic v1, String p2, dynamic v2,
      {bool isAmfHighlight = false}) {
    return Column(
      children: [
        Expanded(
            child: Container(
          color: isAmfHighlight ? Colors.teal : const Color(0xFF374151),
          alignment: Alignment.center,
          child: Text("$p1 ${v1?.toString() ?? "-"}",
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        )),
        const SizedBox(height: 2),
        Expanded(
            child: Container(
          color: const Color(0xFF374151),
          alignment: Alignment.center,
          child: Text("$p2 ${v2?.toString() ?? "-"}",
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        )),
      ],
    );
  }

  Widget _buildPlayerInfo(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Player Info",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildInfoRow("ID", data['id'].toString(), isBlue: true),
          _buildInfoRow("Card Type", data['cardType']),
          _buildInfoRow("Version", data['version']),
          _buildInfoRow("Is Fake", data['isFake'] ? "Fake" : "Real Players"),
          _buildInfoRow("Name", data['name']),
          _buildInfoRow("Age", data['age'].toString()),
          _buildInfoRow("Registered Position", data['position']),
          _buildInfoRow("Playing Styles", data['playstyle']),
          _buildInfoRow("Height", "${data['height']}cm"),
          _buildInfoRow("Weight", "${data['weight']}kg"),
          _buildInfoRow("Max Level Cap", data['maxLevel'].toString()),
          _buildInfoRow("Nationality/Region", data['nationality'],
              isBlue: true),
          _buildInfoRow("Club Team", data['team'], isBlue: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String val, {bool isBlue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(val,
              style: TextStyle(
                  color: isBlue ? const Color(0xFF42A5F5) : Colors.white,
                  fontWeight: isBlue ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Map<String, dynamic> data) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Text("Lv.${data['maxLevel']}",
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                const Icon(Icons.keyboard_arrow_up,
                    color: Colors.black, size: 16)
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.orange, borderRadius: BorderRadius.circular(4)),
            child: Text(data['position'],
                style: const TextStyle(color: Colors.white)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Text("Compare", style: TextStyle(color: Colors.white)),
                Icon(Icons.arrow_drop_down, color: Colors.white)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple Hexagon Painter
class HexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final filledPaint = Paint()
      ..color = const Color(0xFF06DF5D).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF06DF5D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2 * 0.8;

    // Draw background web
    _drawHex(canvas, center, radius, paint);
    _drawHex(canvas, center, radius * 0.7, paint);
    _drawHex(canvas, center, radius * 0.4, paint);

    // Draw stats shape (random visualization for mock)
    final statsPath = Path();
    statsPath.moveTo(center.dx, center.dy - radius * 0.9); // Top
    statsPath.lineTo(center.dx + radius * 0.8, center.dy - radius * 0.3);
    statsPath.lineTo(center.dx + radius * 0.6, center.dy + radius * 0.6);
    statsPath.lineTo(center.dx - radius * 0.5, center.dy + radius * 0.7);
    statsPath.lineTo(center.dx - radius * 0.8, center.dy - radius * 0.2);
    statsPath.lineTo(center.dx - radius * 0.3, center.dy - radius * 0.8);
    statsPath.close();

    canvas.drawPath(statsPath, filledPaint);
    canvas.drawPath(statsPath, borderPaint);
  }

  void _drawHex(Canvas canvas, Offset center, double radius, Paint paint) {
    // Simplified circle for now
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
