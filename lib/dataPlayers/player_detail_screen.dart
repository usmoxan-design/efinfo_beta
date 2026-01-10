import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:efinfo_beta/models/pes_models.dart';
import 'package:efinfo_beta/services/pes_service.dart';
import 'package:efinfo_beta/widgets/pes_player_card_widget.dart';
import 'package:efinfo_beta/widgets/error_display_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  ErrorType? _errorType;
  String? _errorMessage;

  // UI State
  final bool _isFlipped = false;
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

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorType = null;
      _errorMessage = null;
    });

    try {
      // Always fetch level 1 first as base
      if (forceRefresh || _level1Data == null) {
        _level1Data = await _pesService.fetchPlayerDetail(
          widget.player,
          mode: 'level1',
          forceRefresh: forceRefresh,
        );
      }

      // If max level is selected, fetch max level data if needed
      if (_isMaxLevel && (forceRefresh || _maxLevelData == null)) {
        _maxLevelData = await _pesService.fetchPlayerDetail(
          widget.player,
          mode: 'max_level',
          forceRefresh: forceRefresh,
        );
      }

      setState(() {
        _isLoading = false;
        _errorType = null;
        _errorMessage = null;
      });

      // Initialize Simulation State AFTER setState to avoid nested setState
      if (_isMaxLevel && _maxLevelData != null && _level1Data != null) {
        _initializeTrainingState(auto: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          final errorStr = e.toString().toLowerCase();
          if (errorStr.contains('429')) {
            _errorType = ErrorType.serverBusy;
          } else if (errorStr.contains('socketexception') ||
              errorStr.contains('failed host lookup')) {
            _errorType = ErrorType.noInternet;
          } else {
            _errorType = ErrorType.other;
          }
          _errorMessage = e.toString();
        });
      }
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
      affected = ['Finishing', 'Set Piece Taking', 'Curl'];
    } else if (cat.contains('passing'))
      affected = ['Low Pass', 'Lofted Pass'];
    else if (cat.contains('dribbling'))
      affected = ['Dribbling', 'Ball Control', 'Tight Possession'];
    else if (cat.contains('dexterity'))
      affected = ['Attacking Awareness', 'Acceleration', 'Balance'];
    else if (cat.contains('lower body'))
      affected = ['Speed', 'Kicking Power', 'Stamina'];
    else if (cat.contains('aerial') || cat.contains('physical'))
      affected = ['Heading', 'Jumping', 'Physical Contact'];
    else if (cat.contains('defending'))
      affected = [
        'Defensive Awareness',
        'Tackling',
        'Aggression',
        'Defensive Engagement'
      ];
    else if (cat.contains('gk 1'))
      affected = ['GK Awareness', 'Jumping'];
    else if (cat.contains('gk 2'))
      affected = ['GK Parrying', 'GK Reach'];
    else if (cat.contains('gk 3')) affected = ['GK Catching', 'GK Reflex'];

    for (var stat in affected) {
      // Find key case-insensitively to ensure we hit the stat
      String? actualKey;
      for (var k in _currentStats.keys) {
        if (k.toLowerCase() == stat.toLowerCase()) {
          actualKey = k;
          break;
        }
      }

      if (actualKey != null) {
        int val = _currentStats[actualKey]!;
        _currentStats[actualKey] = (val + delta).clamp(1, 99);
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
      String? pesDbStatName;

      // 1. Try direct match (First priority as PesService formats names to match testpage)
      // Case-insensitive check in _currentStats
      for (var k in _currentStats.keys) {
        if (k.toLowerCase() == testpageStatName.toLowerCase()) {
          pesDbStatName = k;
          break;
        }
      }

      // 2. If not found, try mapping (Fallback)
      if (pesDbStatName == null) {
        pesDbToTestpage.forEach((pesDb, testpage) {
          if (testpage == testpageStatName) {
            for (var k in _currentStats.keys) {
              if (k.toLowerCase() == pesDb.toLowerCase()) {
                pesDbStatName = k;
                break;
              }
            }
          }
        });
      }

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? AppColors.background : const Color(0xFFF8F9FA);
    final cardColor = isDark ? AppColors.cardSurface : Colors.white;
    final surfaceColor = isDark ? AppColors.surface : const Color(0xFFF1F3F5);
    final textColor = isDark ? AppColors.textWhite : const Color(0xFF1A1A1A);
    final secondaryTextColor =
        isDark ? AppColors.textDim : const Color(0xFF707070);
    final borderColor =
        isDark ? AppColors.border : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          widget.player.name,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontFamily: GoogleFonts.outfit().fontFamily,
          ),
        ),
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading && (_level1Data == null && !_isMaxLevel)) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.accent));
          }

          if (_isLoading && _isMaxLevel && _maxLevelData == null) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.accent));
          }

          if (_errorType != null && (_level1Data == null)) {
            return Center(
              child: ErrorDisplayWidget(
                errorType: _errorType!,
                errorMessage: _errorMessage,
                onRetry: () => _loadData(forceRefresh: true),
              ),
            );
          }

          final detail = (_isMaxLevel && _maxLevelData != null)
              ? _maxLevelData!
              : _level1Data!;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: LevelToggleHeaderDelegate(
                  isMaxLevel: _isMaxLevel,
                  onToggle: _toggleLevel,
                  backgroundColor: bgColor,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildHeaderSection(
                          detail,
                          isDark,
                          cardColor,
                          surfaceColor,
                          textColor,
                          secondaryTextColor,
                          borderColor),
                      const SizedBox(height: 24),
                      _buildProgressionBar(
                          detail,
                          isDark,
                          cardColor,
                          surfaceColor,
                          textColor,
                          secondaryTextColor,
                          borderColor),
                      const SizedBox(height: 24),
                      if (_isMaxLevel) ...[
                        if (detail.suggestedPoints.isNotEmpty)
                          _buildSuggestedPoints(
                              detail.suggestedPoints,
                              isDark,
                              cardColor,
                              surfaceColor,
                              textColor,
                              secondaryTextColor,
                              borderColor),
                        const SizedBox(height: 24),
                      ],
                      _buildStatsGridWithSim(
                          detail,
                          isDark,
                          cardColor,
                          surfaceColor,
                          textColor,
                          secondaryTextColor,
                          borderColor),
                      const SizedBox(height: 24),
                      _buildSkillsSection(
                          detail,
                          isDark,
                          cardColor,
                          surfaceColor,
                          textColor,
                          secondaryTextColor,
                          borderColor),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(
      PesPlayerDetail detail,
      bool isDark,
      Color cardColor,
      Color surfaceColor,
      Color textColor,
      Color secondaryTextColor,
      Color borderColor) {
    return GlassContainer(
      borderRadius: 24,
      border: isDark ? null : Border.all(color: borderColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'player_${widget.player.id}',
                  child: Container(
                    width: 120,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: PesPlayerCardWidget(
                      player: widget.player,
                      isFlipped: _isFlipped,
                      isMaxLevel: _isMaxLevel,
                      detail: detail,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoTile('Pozitsiyasi:', detail.position,
                        AppColors.accentPink, secondaryTextColor),
                    const SizedBox(height: 12),
                    _buildInfoTile('Yoshi:', detail.age, AppColors.accentGreen,
                        secondaryTextColor),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                        'Bo\'yi',
                        detail.height.contains('sm')
                            ? detail.height
                            : '${detail.height} sm',
                        AppColors.accentOrange,
                        secondaryTextColor),
                    const SizedBox(height: 12),
                    _buildFootTile(detail.foot, secondaryTextColor),
                  ],
                ),
              ],
            ),
          ),
          if (detail.playingStyle != 'Unknown') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(isDark ? 0.3 : 0.5),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Icon(Icons.style_rounded,
                      color: secondaryTextColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Playing Style: ',
                    style: TextStyle(color: secondaryTextColor, fontSize: 13),
                  ),
                  Expanded(
                    child: Text(
                      detail.playingStyle,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      String label, String value, Color accent, Color secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: secondaryTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accent.withOpacity(0.2), width: 1),
          ),
          child: Text(
            value,
            style: TextStyle(
                color: accent, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildFootTile(String foot, Color secondaryTextColor) {
    final bool isRight = foot.toLowerCase().contains('right');
    final String asset = isRight
        ? 'assets/images/right_foot.png'
        : 'assets/images/left_foot.png';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Oyoq:',
          style: TextStyle(
              color: secondaryTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: AppColors.accentBlue.withOpacity(0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(asset, width: 20, height: 20),
              const SizedBox(width: 6),
              Text(
                foot,
                style: const TextStyle(
                    color: AppColors.accentBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGridWithSim(
      PesPlayerDetail detail,
      bool isDark,
      Color cardColor,
      Color surfaceColor,
      Color textColor,
      Color secondaryTextColor,
      Color borderColor) {
    return Column(
      children: [
        if (_isMaxLevel) ...[
          _buildTrainingControls(
              isDark, surfaceColor, textColor, secondaryTextColor, borderColor),
          const SizedBox(height: 24),
        ],
        _buildStatCategory(
          'Hujumkorlik',
          [
            'Attacking Awareness',
            'Ball Control',
            'Dribbling',
            'Tight Possession',
            'Low Pass',
            'Lofted Pass',
            'Finishing',
            'Heading',
            'Curl',
            'Set Piece Taking',
          ],
          detail,
          AppColors.accentPink,
          Icons.sports_soccer_rounded,
          isDark,
          cardColor,
          surfaceColor,
          textColor,
          secondaryTextColor,
          borderColor,
        ),
        const SizedBox(height: 16),
        _buildStatCategory(
          'Himoyaviylik',
          [
            'Defensive Awareness',
            'Tackling',
            'Aggression',
            'Defensive Engagement'
          ],
          detail,
          AppColors.accentBlue,
          Icons.shield_rounded,
          isDark,
          cardColor,
          surfaceColor,
          textColor,
          secondaryTextColor,
          borderColor,
        ),
        const SizedBox(height: 16),
        _buildStatCategory(
          'Fizik holat & Tezlik',
          [
            'Speed',
            'Acceleration',
            'Kicking Power',
            'Jumping',
            'Physical Contact',
            'Balance',
            'Stamina'
          ],
          detail,
          AppColors.accentOrange,
          Icons.bolt_rounded,
          isDark,
          cardColor,
          surfaceColor,
          textColor,
          secondaryTextColor,
          borderColor,
        ),
        const SizedBox(height: 16),
        _buildStatCategory(
          'Darvozabonlik',
          [
            'GK Awareness',
            'GK Catching',
            'GK Parrying',
            'GK Reflex',
            'GK Reach'
          ],
          detail,
          AppColors.accentGreen,
          Icons.pan_tool_rounded,
          isDark,
          cardColor,
          surfaceColor,
          textColor,
          secondaryTextColor,
          borderColor,
        ),
        const SizedBox(height: 16),
        _buildStatCategory(
          'Boshqa statistika',
          [
            'Weak Foot Usage',
            'Weak Foot Accuracy',
            'Form',
            'Injury Resistance',
            'Condition'
          ],
          detail,
          AppColors.accentGreen,
          Icons.tune_rounded,
          isDark,
          cardColor,
          surfaceColor,
          textColor,
          secondaryTextColor,
          borderColor,
        ),
      ],
    );
  }

  Widget _buildStatCategory(
      String title,
      List<String> groupKeys,
      PesPlayerDetail detail,
      Color themeColor,
      IconData icon,
      bool isDark,
      Color cardColor,
      Color surfaceColor,
      Color textColor,
      Color secondaryTextColor,
      Color borderColor) {
    // Collect stats from both stats and info maps with robust matching
    final Map<String, String> categoryData = {};

    // Normalize maps for easier lookup
    final normalizedStats =
        detail.stats.map((k, v) => MapEntry(k.toLowerCase().trim(), v));
    final normalizedInfo =
        detail.info.map((k, v) => MapEntry(k.toLowerCase().trim(), v));

    for (var originalKey in groupKeys) {
      final lookupKey = originalKey.toLowerCase().trim();

      // Use simulated stats if available and in Max Level mode
      if (_isMaxLevel && _currentStats.isNotEmpty) {
        String? simKey;
        for (var k in _currentStats.keys) {
          if (k.toLowerCase().trim() == lookupKey) {
            simKey = k;
            break;
          }
        }

        if (simKey != null) {
          int currentVal = _currentStats[simKey]!;
          int baseVal = 0;

          // Find base value from Level 1 data
          if (_level1Data != null) {
            for (var k in _level1Data!.stats.keys) {
              if (k.toLowerCase().trim() == lookupKey) {
                baseVal = _parseStatValue(_level1Data!.stats[k]!);
                break;
              }
            }
          }

          int diff = currentVal - baseVal;
          if (diff > 0) {
            categoryData[originalKey] = '(+$diff) $currentVal';
          } else {
            categoryData[originalKey] = currentVal.toString();
          }
          continue;
        }
      }

      if (normalizedStats.containsKey(lookupKey)) {
        categoryData[originalKey] = normalizedStats[lookupKey]!;
      } else if (normalizedInfo.containsKey(lookupKey)) {
        categoryData[originalKey] = normalizedInfo[lookupKey]!;
      }
    }

    if (categoryData.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Icon(icon, color: themeColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              children: categoryData.entries.map((entry) {
                final key = entry.key;
                final valueStr = entry.value;
                final value = _parseStatValue(valueStr);
                final color = _getStatColor(value);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: value > 0
                              ? color
                              : secondaryTextColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          PesService.formatStatName(key),
                          style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          if (valueStr.contains('(') &&
                              valueStr.contains(')')) {
                            int closeIdx = valueStr.indexOf(')');
                            String boost = valueStr.substring(0, closeIdx + 1);
                            String val = valueStr.substring(closeIdx + 1);
                            return RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: boost,
                                    style: TextStyle(
                                        color: value > 0 ? color : textColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  const WidgetSpan(child: SizedBox(width: 4)),
                                  TextSpan(
                                    text: val,
                                    style: TextStyle(
                                        color: value > 0 ? color : textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Text(
                            valueStr,
                            style: TextStyle(
                                color: value > 0 ? color : textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionBar(
      PesPlayerDetail detail,
      bool isDark,
      Color cardColor,
      Color surfaceColor,
      Color textColor,
      Color secondaryTextColor,
      Color borderColor) {
    if (!_isMaxLevel) {
      int ovr = int.tryParse(detail.stats['Overall Rating'] ?? '0') ?? 0;
      Color bg = _getStatColor(ovr);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Current Level",
                    style: TextStyle(color: secondaryTextColor, fontSize: 11)),
                const SizedBox(height: 2),
                Text("Level 1",
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: bg.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: bg.withOpacity(0.3), width: 1),
              ),
              child: Text(
                "OVR: $ovr",
                style: TextStyle(
                    color: bg, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    int dynamicOvr = _dynamicOvr;
    int remaining = _totalPoints - _usedPoints;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Progression Points",
                      style:
                          TextStyle(color: secondaryTextColor, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text("$remaining / $_totalPoints",
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
              Row(
                children: [
                  _buildOvrBadge("Max", dynamicOvr, isDark, textColor,
                      secondaryTextColor, borderColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _totalPoints > 0 ? _usedPoints / _totalPoints : 0,
              backgroundColor: isDark ? AppColors.background : surfaceColor,
              color: AppColors.accent,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingControls(bool isDark, Color surfaceColor,
      Color textColor, Color secondaryTextColor, Color borderColor) {
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
              Text(
                "Training Simulation",
                style: TextStyle(
                    color: textColor,
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
                  color: isDark ? const Color(0xFF0D2418) : surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(key.replaceAll('Progression Points', '').trim(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => _updateTrainingCategory(key, false),
                          child: const Icon(Icons.remove_circle,
                              color: Colors.orange, size: 22),
                        ),
                        const SizedBox(width: 4),
                        Text("$value",
                            style: TextStyle(
                                color: textColor,
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
                    const SizedBox(height: 8),
                    _buildStatSvgIcon(key, size: 16, isDark: isDark),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(
      PesPlayerDetail detail,
      bool isDark,
      Color cardColor,
      Color surfaceColor,
      Color textColor,
      Color secondaryTextColor,
      Color borderColor) {
    if (detail.skills.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded,
                    color: AppColors.accentBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Player Skills",
                  style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: detail.skills.map((skill) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatSvgIcon(String key, {double size = 16, bool isDark = true}) {
    final k = key.toLowerCase();
    String assetPath = 'assets/images/shooting.svg';

    if (k.contains('shooting') || k.contains('finishing')) {
      assetPath = 'assets/images/shooting.svg';
    } else if (k.contains('passing') || k.contains('pass')) {
      assetPath = 'assets/images/passing.svg';
    } else if (k.contains('dribbling') || k.contains('ball control')) {
      assetPath = 'assets/images/dribbling.svg';
    } else if (k.contains('dexterity') ||
        k.contains('speed') ||
        k.contains('acceleration')) {
      assetPath = 'assets/images/dexterity.svg';
    } else if (k.contains('defending') || k.contains('awareness')) {
      assetPath = 'assets/images/defending.svg';
    } else if (k.contains('gk')) {
      assetPath = 'assets/images/goalkeepeing.svg';
    } else if (k.contains('aerial') || k.contains('jumping')) {
      assetPath = 'assets/images/aerial_strength.svg';
    } else if (k.contains('lower body') ||
        k.contains('strength') ||
        k.contains('physical')) {
      assetPath = 'assets/images/lower_body_strength.svg';
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white : Colors.black.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(
            isDark ? Colors.black : Colors.black, BlendMode.srcIn),
      ),
    );
  }

  int _parseStatValue(String value) {
    final match = RegExp(r'^(\d+)').firstMatch(value);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 0;
    }
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
      for (final key in data.stats.keys) {
        if (key.toLowerCase() == 'overall rating') {
          val = data.stats[key];
          break;
        }
      }
    }
    return _parseStatValue(val ?? '0');
  }

  Color _getStatColor(int val) {
    if (val >= 90) return const Color(0xFF07FCF5);
    if (val >= 80) return const Color(0xFF05fd07);
    if (val >= 70) return const Color(0xFFfcaa04);
    return const Color(0xFFd74233);
  }

  Widget _buildOvrBadge(String label, int ovr, bool isDark, Color textColor,
      Color secondaryTextColor, Color borderColor,
      {bool isSmall = false}) {
    Color bg = _getStatColor(ovr);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 10 : 14, vertical: isSmall ? 4 : 8),
      decoration: BoxDecoration(
        color: isSmall
            ? (isDark ? AppColors.background : const Color(0xFFF1F3F5))
            : bg.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isSmall ? borderColor : bg.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: isSmall ? secondaryTextColor : bg,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
          Text(
            ovr.toString(),
            style: TextStyle(
                color: isSmall ? textColor : bg,
                fontWeight: FontWeight.bold,
                fontSize: isSmall ? 14 : 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedPoints(
      Map<String, int> points,
      bool isDark,
      Color cardColor,
      Color surfaceColor,
      Color textColor,
      Color secondaryTextColor,
      Color borderColor) {
    if (points.isEmpty) return const SizedBox.shrink();

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
      if (!exists) mergedPoints[cat] = 0;
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: AppColors.accentOrange, size: 20),
                const SizedBox(width: 8),
                Text("To'g'ri kuchaytirish",
                    style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double spacing = 8;
                final double itemWidth =
                    (constraints.maxWidth - (spacing * 3)) / 4;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: entries.map((e) {
                    bool isTotal = e.key.toLowerCase().contains('total') ||
                        e.key.toLowerCase().contains('progression points');
                    String displayKey = isTotal ? "Total Pts" : e.key;
                    return Container(
                      width: itemWidth,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isTotal
                            ? AppColors.accentPink.withOpacity(0.1)
                            : surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isTotal
                                ? AppColors.accentPink.withOpacity(0.3)
                                : borderColor,
                            width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatSvgIcon(e.key, size: 14, isDark: isDark),
                          const SizedBox(height: 6),
                          Text(
                              displayKey
                                  .replaceAll('Progression Points', '')
                                  .trim(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: isTotal
                                      ? AppColors.accentPink
                                      : secondaryTextColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('${e.value}',
                              style: TextStyle(
                                  color: isTotal
                                      ? AppColors.accentPink
                                      : textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
