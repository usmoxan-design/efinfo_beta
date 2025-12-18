// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:efinfo_beta/models/pes_models.dart';
import 'package:efinfo_beta/services/pes_service.dart';
import 'package:efinfo_beta/widgets/pes_player_card_widget.dart';
import 'level_toggle_header_delegate.dart';

class PesPlayerDetailScreen extends StatefulWidget {
  final PesPlayer player;

  const PesPlayerDetailScreen({super.key, required this.player});

  @override
  State<PesPlayerDetailScreen> createState() => _PesPlayerDetailScreenState();
}

class _PesPlayerDetailScreenState extends State<PesPlayerDetailScreen> {
  final PesService _pesService = PesService();

  // State for data
  PesPlayerDetail? _level1Data;
  PesPlayerDetail? _maxLevelData;
  bool _isLoading = true;
  String? _error;

  // UI State
  bool _isFlipped = false;
  bool _isMaxLevel = false;

  // Training Simulation State
  Map<String, int> _allocatedPoints = {};
  Map<String, int> _currentStats = {};
  int _usedPoints = 0;
  int _totalPoints = 0;
  int _dynamicOvr = 0;

  // Position Weights for OVR Calculation (matching testpage.dart exactly)
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
      'GK Reflex': 0.25,
      'GK Parrying': 0.20,
      'GK Catching': 0.15,
      'GK Reach': 0.15,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Always fetch level 1 first as base
      _level1Data ??= await _pesService.fetchPlayerDetail(
        widget.player,
        mode: 'level1',
      );

      // If max level is selected, fetch max level data if needed
      if (_isMaxLevel && _maxLevelData == null) {
        _maxLevelData = await _pesService.fetchPlayerDetail(
          widget.player,
          mode: 'max_level',
        );
      }

      setState(() {
        _isLoading = false;
      });

      // Initialize Simulation State AFTER setState to avoid nested setState
      if (_isMaxLevel && _maxLevelData != null && _level1Data != null) {
        _initializeTrainingState(auto: true);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _initializeTrainingState({bool auto = true}) {
    if (_maxLevelData == null || _level1Data == null) return;

    setState(() {
      // 1. Determine Total Available Points
      int pts = 0;
      _maxLevelData!.suggestedPoints.forEach((k, v) {
        if (k.toLowerCase().contains('total') ||
            k.toLowerCase().contains('progression')) {
          pts = v;
        }
      });

      // If not found, sum up the costs of suggested points or default categories
      if (pts == 0) {
        _maxLevelData!.suggestedPoints.forEach((k, v) {
          if (!k.toLowerCase().contains('total')) {
            pts += _calculateCostForLevel(v);
          }
        });
      }
      _totalPoints = pts > 0 ? pts : 60; // Fallback 60

      // Define all standard categories to ensure they exist in map
      final allCategories = [
        'Shooting',
        'Passing',
        'Dribbling',
        'Dexterity',
        'Lower Body Strength',
        'Aerial Strength',
        'Defending',
        'GK 1',
        'GK 2',
        'GK 3'
      ];

      if (auto) {
        // AUTO mode: Set points as suggested
        _allocatedPoints = {};

        // Fill from suggestions, normalizing keys
        _maxLevelData!.suggestedPoints.forEach((k, v) {
          if (!k.toLowerCase().contains('total') &&
              !k.toLowerCase().contains('progression')) {
            _allocatedPoints[k] = v;
          }
        });

        // Ensure all standard categories exist (default 0)
        for (var cat in allCategories) {
          if (!_allocatedPoints.keys
              .any((k) => k.toLowerCase() == cat.toLowerCase())) {
            _allocatedPoints[cat] = 0;
          }
        }

        _usedPoints = 0;
        _allocatedPoints.forEach((key, val) {
          _usedPoints += _calculateCostForLevel(val);
        });

        // Initialize stats to Max Level values directly
        _currentStats = {};
        _maxLevelData!.stats.forEach((k, v) {
          int val = _parseStatValue(v);
          // Only add if non-zero or if the string was valid 0?
          // _parseStatValue returns 0 if fail.
          // Pes stats are rarely 0 except maybe GK stats for field players? No they are 40+.
          if (val > 0 || v == '0') _currentStats[k] = val;
        });

        // In Auto mode, the OVR should match the Max Level OVR from data
        _dynamicOvr = _getOvrFromData(_maxLevelData);
      } else {
        // RESET mode: Set all points to 0
        _allocatedPoints.clear();
        for (var cat in allCategories) {
          _allocatedPoints[cat] = 0;
        }

        _usedPoints = 0;

        // Reset stats to Level 1 base
        _currentStats = {};
        _level1Data!.stats.forEach((k, v) {
          int val = _parseStatValue(v);
          if (val > 0 || v == '0') _currentStats[k] = val;
        });

        // Recalculate OVR for reset mode
        _recalculateOVR();
      }
    });
  }

  int _calculateCostForLevel(int level) {
    // 1-4: 1 pt each
    // 5-8: 2 pts each
    // ...
    int cost = 0;
    for (int i = 1; i <= level; i++) {
      cost += ((i - 1) ~/ 4) + 1;
    }
    return cost;
  }

  void _updateTrainingCategory(String category, bool increase) {
    if (!_isMaxLevel) return;

    int currentLevel = _allocatedPoints[category] ?? 0;

    setState(() {
      if (increase) {
        int cost = (currentLevel ~/ 4) + 1;
        // Constraint: Can't exceed total points
        if (_usedPoints + cost <= _totalPoints) {
          if (currentLevel < 99) {
            _allocatedPoints[category] = currentLevel + 1;
            _usedPoints += cost;
            _applyStatChanges(category, 1);
          }
        } else {
          // Optional: Show snackbar "Not enough points"
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Insufficient points!"),
              duration: Duration(milliseconds: 500)));
        }
      } else {
        if (currentLevel > 0) {
          int costOfCurrent = ((currentLevel - 1) ~/ 4) + 1;
          _allocatedPoints[category] = currentLevel - 1;
          _usedPoints -= costOfCurrent;
          _applyStatChanges(category, -1);
        }
      }
      _recalculateOVR();
    });
  }

  void _applyStatChanges(String category, int delta) {
    List<String> affected = [];
    String cat = category.toLowerCase();

    if (cat.contains('shooting')) {
      affected = ['Finishing', 'Place Kicking', 'Curl'];
    } else if (cat.contains('passing'))
      affected = ['Low Pass', 'Lofted Pass'];
    else if (cat.contains('dribbling'))
      affected = ['Dribbling', 'Ball Control', 'Tight Possession'];
    else if (cat.contains('dexterity'))
      affected = ['Offensive Awareness', 'Acceleration', 'Balance'];
    else if (cat.contains('lower body'))
      affected = ['Speed', 'Kicking Power', 'Stamina'];
    else if (cat.contains('aerial') || cat.contains('physical'))
      affected = ['Heading', 'Jump', 'Physical Contact'];
    else if (cat.contains('defending'))
      affected = [
        'Defensive Awareness',
        'Tackling',
        'Aggression',
        'Defensive Engagement'
      ];
    else if (cat.contains('gk 1'))
      affected = ['GK Awareness', 'Jump'];
    else if (cat.contains('gk 2'))
      affected = ['GK Parrying', 'GK Reach'];
    else if (cat.contains('gk 3')) affected = ['GK Catching', 'GK Reflexes'];

    for (var stat in affected) {
      if (_currentStats.containsKey(stat)) {
        int val = _currentStats[stat]!;
        _currentStats[stat] = (val + delta).clamp(1, 99);
      }
    }
  }

  void _recalculateOVR() {
    // Use Weighted Calculation matching testpage.dart
    if (_maxLevelData == null || _currentStats.isEmpty) {
      print("DEBUG OVR: maxLevelData or currentStats is empty");
      return;
    }

    String position = _maxLevelData!.position;
    String posKey = position;
    if (position == 'RB' || position == 'LB') posKey = 'LB/RB';
    if (position == 'LWF' || position == 'RWF') posKey = 'LWF/RWF';

    print("DEBUG OVR: Position = $position, PosKey = $posKey");

    var weights = positionWeights[posKey] ?? {};

    if (weights.isEmpty) {
      // Fallback if position unknown
      _dynamicOvr = _getOvrFromData(_maxLevelData);
      print("DEBUG OVR: No weights found, using fallback OVR = $_dynamicOvr");
      return;
    }

    double totalWeightedScore = 0.0;
    double totalWeights = 0.0;

    // Map PesDB stat names to testpage.dart stat names used in weights
    // PesDB uses different names than testpage.dart
    Map<String, String> pesDbToTestpage = {
      // PesDB Name -> testpage.dart name (used in weights)
      'Offensive Awareness': 'Attacking Awareness',
      'Ball Control': 'Ball Control',
      'Dribbling': 'Dribbling',
      'Tight Possession': 'Tight Possession',
      'Low Pass': 'Low Pass',
      'Lofted Pass': 'Lofted Pass',
      'Finishing': 'Finishing',
      'Heading': 'Heading',
      'Place Kicking': 'Set Piece Taking',
      'Curl': 'Curl',
      'Speed': 'Speed',
      'Acceleration': 'Acceleration',
      'Kicking Power': 'Kicking Power',
      'Jump': 'Jumping',
      'Physical Contact': 'Physical Contact',
      'Balance': 'Balance',
      'Stamina': 'Stamina',
      'Defensive Awareness': 'Defensive Awareness',
      'Tackling': 'Tackling',
      'Aggression': 'Aggression',
      'Defensive Engagement': 'Defensive Engagement',
      'GK Awareness': 'GK Awareness',
      'GK Catching': 'GK Catching',
      'GK Parrying': 'GK Parrying',
      'GK Reflexes': 'GK Reflex',
      'GK Reach': 'GK Reach',
    };

    int matchedStats = 0;
    // For each weight requirement, find the matching stat
    weights.forEach((testpageStatName, weight) {
      // Find which PesDB stat name maps to this testpage stat name
      String? pesDbStatName;
      pesDbToTestpage.forEach((pesDb, testpage) {
        if (testpage == testpageStatName && _currentStats.containsKey(pesDb)) {
          pesDbStatName = pesDb;
        }
      });

      if (pesDbStatName != null) {
        int val = _currentStats[pesDbStatName!] ?? 40;
        totalWeightedScore += val * weight;
        totalWeights += weight;
        matchedStats++;
        if (matchedStats <= 3) {
          print(
              "DEBUG OVR: Matched $testpageStatName -> $pesDbStatName = $val (weight: $weight)");
        }
      } else {
        if (matchedStats <= 3) {
          print("DEBUG OVR: NOT FOUND $testpageStatName");
        }
      }
    });

    print(
        "DEBUG OVR: Total matched stats = $matchedStats, totalWeights = $totalWeights");

    if (totalWeights == 0) {
      _dynamicOvr = 0;
      print("DEBUG OVR: Total weights is 0, setting OVR to 0");
      return;
    }

    // Exact formula from testpage.dart
    double weightedAverage = totalWeightedScore / totalWeights;
    double boost = 0;
    if (weightedAverage > 70) {
      boost = (weightedAverage - 70) * 0.5;
    }

    _dynamicOvr = (weightedAverage + boost + 4).round();
    print(
        "DEBUG OVR: weightedAverage = $weightedAverage, boost = $boost, final OVR = $_dynamicOvr");
  }

  void _toggleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _toggleLevel(bool isMax) {
    if (_isMaxLevel != isMax) {
      setState(() {
        _isMaxLevel = isMax;
        if (!_isMaxLevel) {
          _currentStats.clear();
        } else {
          if (_maxLevelData != null) {
            _initializeTrainingState(auto: true);
          } else {
            _loadData();
          }
        }
      });
      if (isMax && _maxLevelData == null) {
        _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011A0B), // AppColors.background
      appBar: AppBar(
        title: Text(
          widget.player.name,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: const Color(0xFF1A1A1A), // AppColors.surface
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading && (_level1Data == null && !_isMaxLevel)) {
            return const Center(child: CircularProgressIndicator());
          }

          // If max level but data missing, showing loading until data arrives
          if (_isLoading && _isMaxLevel && _maxLevelData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error != null && (_level1Data == null)) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Error: $_error",
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        _loadData();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06DF5D),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final detail = (_isMaxLevel && _maxLevelData != null)
              ? _maxLevelData!
              : _level1Data!;

          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: LevelToggleHeaderDelegate(
                  isMaxLevel: _isMaxLevel,
                  onToggle: _toggleLevel,
                ),
              ),
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildHeaderSection(detail),
                    const SizedBox(height: 16),
                    _buildProgressionBar(detail),
                    const SizedBox(height: 16),
                    if (_isMaxLevel) ...[
                      if (detail.suggestedPoints.isNotEmpty)
                        _buildSuggestedPoints(detail.suggestedPoints),
                      // _buildTrainingControls(),
                    ],
                    const SizedBox(height: 16),
                    _buildStatsGridWithSim(detail),
                    const SizedBox(height: 24),
                    _buildSkillsSection(detail),
                    const SizedBox(height: 50),
                  ],
                ),
              )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(PesPlayerDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2418), // AppColors.cardSurface
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF06DF5D),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              height: 200,
              child: PesPlayerCardWidget(
                player: widget.player,
                detail: detail,
                onFlip: _toggleFlip,
                isFlipped: _isFlipped,
                isMaxLevel: _isMaxLevel,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.player.name,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Yoshi: ${detail.age} Bo'yi: ${detail.height}cm Vazni: ${detail.stats['Weight'] ?? '-'}kg",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  if (detail.foot.toLowerCase().contains('right'))
                    Image.asset('assets/images/right_foot.png',
                        width: 20, height: 20)
                  else if (detail.foot.toLowerCase().contains('left'))
                    Image.asset('assets/images/left_foot.png',
                        width: 20, height: 20)
                  else
                    Text(
                      detail.foot,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            detail.playingStyle,
            style: const TextStyle(
                color: Color(0xFF06DF5D), fontSize: 13), // AppColors.accent
          ),
          const SizedBox(height: 5),
          Text(
            detail.position,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionBar(PesPlayerDetail detail) {
    // 1. Level 1 Mode: Show only Data OVR
    if (!_isMaxLevel) {
      int ovr = int.tryParse(detail.stats['Overall Rating'] ?? '0') ?? 0;
      Color bg = _getStatColor(ovr);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: const Color(0xFF011A0B),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text("Level 1",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(4)),
              child: Text("OVR: $ovr",
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    }

    // 2. Max Level Mode: Show Pts + Dual OVR (Max & Sim)
    int dynamicOvr = _dynamicOvr;
    // Base Max is the OVR from the max level data (the "Potential" or "suggested" OVR)
    // This should always be the Max Level OVR from the data, not the simulated one
    // Base Max is the OVR from the max level data (the "Potential" or "suggested" OVR)
    // This should always be the Max Level OVR from the data, not the simulated one
    int baseMaxOvr = _getOvrFromData(_maxLevelData);

    // Remaining points
    int remaining = _totalPoints - _usedPoints;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF011A0B),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Points & Toggle Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pts: $remaining / $_totalPoints",
                    style: const TextStyle(
                        color: Color(0xFF06DF5D),
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Max Level",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Right: OVRs
          Row(
            children: [
              // Static Max OVR (The target/reference from data)

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Max Rated",
                      style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatColor(baseMaxOvr),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text("$baseMaxOvr",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Dynamic Simulated OVR
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   children: [
              //     const Text("Simulated",
              //         style: TextStyle(color: Color(0xFF06DF5D), fontSize: 10)),
              //     Container(
              //       padding:
              //           const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              //       decoration: BoxDecoration(
              //         color: _getStatColor(dynamicOvr),
              //         borderRadius: BorderRadius.circular(4),
              //       ),
              //       child: Text(
              //         "$dynamicOvr",
              //         style: const TextStyle(
              //             color: Colors.black,
              //             fontWeight: FontWeight.bold,
              //             fontSize: 16),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTrainingControls() {
    var keys = _allocatedPoints.keys.toList();
    // Custom sort to match game order roughly
    final sortOrder = [
      'Shooting',
      'Passing',
      'Dribbling',
      'Dexterity',
      'Lower Body Strength',
      'Aerial Strength',
      'Defending',
      'GK 1',
      'GK 2',
      'GK 3'
    ];

    keys.sort((a, b) {
      int idxA =
          sortOrder.indexWhere((s) => s.toLowerCase() == a.toLowerCase());
      int idxB =
          sortOrder.indexWhere((s) => s.toLowerCase() == b.toLowerCase());
      if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
      if (idxA != -1) return -1;
      if (idxB != -1) return 1;
      return a.compareTo(b);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Training Simulation",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => _initializeTrainingState(auto: true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF06DF5D)),
                          borderRadius: BorderRadius.circular(4)),
                      child: const Text("Auto",
                          style: TextStyle(
                              color: Color(0xFF06DF5D),
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ),
                  InkWell(
                    onTap: () => _initializeTrainingState(auto: false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.redAccent),
                          borderRadius: BorderRadius.circular(4)),
                      child: const Text("Reset",
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: keys.length,
            itemBuilder: (context, index) {
              String key = keys[index];
              int value = _allocatedPoints[key] ?? 0;
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2418),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(key.replaceAll('Progression Points', '').trim(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          // Enable visual touch but logic handles constraints
                          onTap: () => _updateTrainingCategory(key, false),
                          child: const Icon(Icons.remove_circle,
                              color: Colors.orange, size: 22),
                        ),
                        const SizedBox(width: 4),
                        Text("$value",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => _updateTrainingCategory(key, true),
                          child: const Icon(Icons.add_circle,
                              color: Color(0xFF06DF5D), size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Icon(_getStatIcon(key), color: Colors.white30, size: 16)
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildStatsGridWithSim(PesPlayerDetail detail) {
    if (!_isMaxLevel) {
      return _buildStatsGrid(detail);
    }

    Map<String, String> simulatedStats = Map.from(detail.stats);
    _currentStats.forEach((k, v) {
      simulatedStats[k] = v.toString();
    });

    PesPlayerDetail simDetail = PesPlayerDetail(
        player: detail.player,
        position: detail.position,
        height: detail.height,
        age: detail.age,
        foot: detail.foot,
        stats: simulatedStats,
        info: detail.info,
        playingStyle: detail.playingStyle,
        skills: detail.skills,
        suggestedPoints: detail.suggestedPoints,
        description: detail.description);

    return _buildStatsGrid(simDetail);
  }

  Widget _buildStatsGrid(PesPlayerDetail detail) {
    final Map<String, List<String>> categories = {
      'Attacking': [
        'Offensive Awareness',
        'Ball Control',
        'Dribbling',
        'Tight Possession',
        'Low Pass',
        'Lofted Pass',
        'Finishing',
        'Heading',
        'Place Kicking',
        'Curl'
      ],
      'Defending': [
        'Defensive Awareness',
        'Tackling',
        'Aggression',
        'Defensive Engagement'
      ],
      'Physical': [
        'Speed',
        'Acceleration',
        'Kicking Power',
        'Jump',
        'Physical Contact',
        'Balance',
        'Stamina'
      ],
      'Goalkeeping': [
        'GK Awareness',
        'GK Catching',
        'GK Parrying',
        'GK Reflexes',
        'GK Reach'
      ]
    };

    List<Widget> categoryWidgets = [];
    Set<String> shownStats = {};
    final excludedKeys = [
      'Squad Number',
      'Weight',
      'Maximum Level',
      'Age',
      'Height',
      'Overall Rating',
      'Position',
      'Foot'
    ];

    categories.forEach((title, keys) {
      List<MapEntry<String, String>> groupStats = [];
      for (var k in keys) {
        if (detail.stats.containsKey(k)) {
          groupStats.add(MapEntry(k, detail.stats[k]!));
          shownStats.add(k);
        } else if (detail.info.containsKey(k)) {
          String val = detail.info[k]!;
          if (RegExp(r'\d+').hasMatch(val)) {
            groupStats.add(MapEntry(k, val));
            shownStats.add(k);
          }
        }
      }

      if (groupStats.isNotEmpty) {
        categoryWidgets.add(_buildStatCategory(title, groupStats));
      }
    });

    List<MapEntry<String, String>> others = [];
    detail.stats.forEach((k, v) {
      if (!shownStats.contains(k) && !excludedKeys.contains(k)) {
        others.add(MapEntry(k, v));
      }
    });

    if (others.isNotEmpty) {
      categoryWidgets.add(_buildStatCategory('Other Stats', others));
    }

    categoryWidgets.add(const SizedBox(height: 10));
    categoryWidgets.add(Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2418),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            _buildGenericStatRow(
                "Weak Foot Usage",
                detail.info['Weak Foot Usage'],
                "Weak Foot Accuracy",
                detail.info['Weak Foot Accuracy']),
            const Divider(color: Colors.white10),
            _buildGenericStatRow("Form", detail.info['Form'],
                "Injury Resistance", detail.info['Injury Resistance']),
          ],
        )));

    return Column(children: categoryWidgets);
  }

  Widget _buildStatCategory(
      String title, List<MapEntry<String, String>> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 8.0),
          child: Text(
            title,
            style: const TextStyle(
                color: Color(0xFF06DF5D),
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0D2418), // Card surface
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: _buildGridRows(stats),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGridRows(List<MapEntry<String, String>> stats) {
    List<Widget> rows = [];
    for (int i = 0; i < stats.length; i += 2) {
      if (i + 1 >= stats.length) {
        var e = stats[i];
        rows.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(child: _buildStatItemWithComparison(e.key, e.value)),
              const SizedBox(width: 10),
              const Spacer(),
            ],
          ),
        ));
        break;
      }
      var e1 = stats[i];
      var e2 = stats[i + 1];

      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: _buildStatItemWithComparison(e1.key, e1.value)),
            const SizedBox(width: 10),
            Expanded(child: _buildStatItemWithComparison(e2.key, e2.value)),
          ],
        ),
      ));
    }
    return rows;
  }

  Widget _buildStatItemWithComparison(String label, String valueStr) {
    String? augmentation;
    int value = _parseStatValue(valueStr);

    if (_isMaxLevel && _level1Data != null) {
      String? l1ValStr = _level1Data?.stats[label];
      if (l1ValStr != null) {
        int l1Value = _parseStatValue(l1ValStr);
        int diff = value - l1Value;
        if (diff > 0) {
          augmentation = "+$diff";
        }
      }
    }

    if (augmentation == null) {
      final augMatch = RegExp(r'\(\+(\d+)\)\s*(\d+)').firstMatch(valueStr);
      if (augMatch != null) {
        augmentation = "+${augMatch.group(1)}";
      }
    }

    Color bg = _getStatColor(value);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              if (augmentation != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    augmentation,
                    style: const TextStyle(
                      color: Color(0xFF06DF5D),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Container(
                width: 35,
                height: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "$value",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenericStatRow(String l1, String? v1, String l2, String? v2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l1,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(v1 ?? "-",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l2,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(v2 ?? "-",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(PesPlayerDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Player Skills",
            style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: detail.skills
              .map((s) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D2418),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(s,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ))
              .toList(),
        ),
        if (detail.info.containsKey("AI Playing Styles")) ...[
          const SizedBox(height: 16),
          const Text("AI Playing Styles",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0D2418),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(detail.info["AI Playing Styles"]!,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          )
        ]
      ],
    );
  }

  IconData _getStatIcon(String key) {
    key = key.toLowerCase();
    if (key.contains('total') || key.contains('progression')) {
      return Icons.circle;
    }
    if (key.contains('shooting')) return Icons.gps_fixed;
    if (key.contains('passing')) return Icons.sports_soccer;
    if (key.contains('dribbling')) return Icons.change_history;
    if (key.contains('dexterity')) return Icons.compare_arrows;
    if (key.contains('lower body')) return Icons.directions_run;
    if (key.contains('aerial') ||
        key.contains('defending') ||
        key.contains('physical')) return Icons.shield;
    if (key.contains('gk')) return Icons.pan_tool;
    return Icons.circle;
  }

  int _parseStatValue(String value) {
    // Determine if value contains a number
    // "100" -> 100
    // "103" -> 103
    // "85 (+3)" -> 85 (or 88? Usually we want the base value if + is boost, but here we want the main value)

    // If the string is purely digits:
    if (RegExp(r'^\d+$').hasMatch(value)) {
      return int.tryParse(value) ?? 0;
    }

    // If it has format "100 (+3)", we typically want the first number?
    // PesService puts standard stats as just number.
    // Let's extract all digits and take the first group if separated?

    // Safer: Remove non-digits and parse? No, "100 (+3)" -> 1003.
    // Take the first sequence of digits.
    final match = RegExp(r'^(\d+)').firstMatch(value);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 0;
    }

    // Fallback to original logic (digits at end)
    final matchEnd = RegExp(r'(\d+)$').firstMatch(value);
    if (matchEnd != null) {
      return int.tryParse(matchEnd.group(1)!) ?? 0;
    }

    return 0;
  }

  int _getOvrFromData(PesPlayerDetail? data) {
    if (data == null) return 0;
    String? val = data.stats['Overall Rating'];
    if (val == null) {
      // Case-insensitive fallback
      for (final key in data.stats.keys) {
        if (key.toLowerCase() == 'overall rating') {
          val = data.stats[key];
          break;
        }
      }
    }
    return _parseStatValue(val ?? '0');
  }

  // Color _getStatColor(int val) {
  //   if (val >= 90) return Colors.cyanAccent;
  //   if (val >= 80) return Colors.lightGreenAccent;
  //   if (val < 70) return Colors.redAccent;
  //   return Colors.white; // 70-79
  // }

  Color _getStatColor(int val) {
    if (val >= 90) {
      return const Color(0xFF07FCF5);
    } else if (val >= 80) {
      return const Color(0xFF05fd07);
    } else if (val >= 65) {
      return const Color(0xFFfcaa04);
    } else {
      return const Color(0xFFd74233);
    }
  }

  Widget _buildSuggestedPoints(Map<String, int> points) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<String> standardCategories = [
      'Shooting',
      'Passing',
      'Dribbling',
      'Dexterity',
      'Lower Body Strength',
      'Aerial Strength',
      'Defending',
      'GK 1',
      'GK 2',
      'GK 3',
    ];

    Map<String, int> mergedPoints = {};

    points.forEach((k, v) {
      if (!k.toLowerCase().contains('suggested points for level')) {
        mergedPoints[k] = v;
      }
    });

    for (var cat in standardCategories) {
      bool exists =
          mergedPoints.keys.any((k) => k.toLowerCase() == cat.toLowerCase());
      if (!exists) {
        mergedPoints[cat] = 0;
      }
    }

    var entries = mergedPoints.entries.toList();

    entries.sort((a, b) {
      bool aIsTotal = a.key.toLowerCase().contains('total') ||
          a.key.toLowerCase().contains('progression points');
      bool bIsTotal = b.key.toLowerCase().contains('total') ||
          b.key.toLowerCase().contains('progression points');
      if (aIsTotal && !bIsTotal) return -1;
      if (!aIsTotal && bIsTotal) return 1;

      int idxA = standardCategories
          .indexWhere((c) => c.toLowerCase() == a.key.toLowerCase());
      int idxB = standardCategories
          .indexWhere((c) => c.toLowerCase() == b.key.toLowerCase());

      if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
      if (idxA != -1) return -1;
      if (idxB != -1) return 1;

      return a.key.compareTo(b.key);
    });

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "To'g'ri kuchaytirish:",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final e = entries[index];
              bool isTotal = e.key.toLowerCase().contains('total') ||
                  e.key.toLowerCase().contains('progression points');

              String displayKey = e.key;
              if (isTotal) {
                displayKey = "Max Progress Points";
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: isTotal
                      ? const Color(0xFF005929)
                      : const Color(0xFF0D2418),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isTotal
                        ? const Color(0xFF06DF5D)
                        : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayKey.replaceAll('Progression Points', '').trim(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            isTotal ? const Color(0xFF06DF5D) : Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getStatIcon(e.key),
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${e.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
