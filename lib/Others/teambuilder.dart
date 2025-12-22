import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:efinfo_beta/Others/imageSaver.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:efinfo_beta/Others/pitchpainter.dart';
import 'package:efinfo_beta/models/pes_models.dart';
import 'package:efinfo_beta/services/pes_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:efinfo_beta/utils/platform_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamBuilderScreen extends StatefulWidget {
  const TeamBuilderScreen({super.key});

  @override
  State<TeamBuilderScreen> createState() => _TeamBuilderScreenState();
}

class _TeamBuilderScreenState extends State<TeamBuilderScreen> {
  final PesService _pesService = PesService();
  final WidgetsToImageController _screenshotController =
      WidgetsToImageController();

  // // Yangi: RepaintBoundary ni boshqarish uchun Global Key e'lon qiling
  final GlobalKey _pitchBoundaryKey = GlobalKey();

  final List<SquadFormation> _formations = [];
  late SquadFormation _currentFormation;
  Map<String, PesPlayer?> _squad = {};

  // Search state
  List<PesPlayer> _searchResults = [];
  bool _isSearching = false;
  String? _selectedSpot;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formations.addAll(_getBuiltInFormations());
    _currentFormation = _formations.first;
    _initializeSquad();
    _loadSavedSquad();
  }

  Future<void> _autoPick() async {
    setState(() => _isSearching = true);
    try {
      // Fetch top 100 players sorted by max OVR
      final players = await _pesService.fetchPlayers(
        filters: {
          'all': '1',
          'sort': 'overall_at_max_level',
          'order': 'desc',
          'mode': 'max_level'
        },
      );

      if (players.isEmpty) throw 'Hech qanday o\'yinchi topilmadi';

      final Map<String, PesPlayer?> newSquad = {};
      final List<String> usedIds = [];

      // Create a copy of current formation spots
      final spots = _currentFormation.positions.keys.toList();

      for (var spot in spots) {
        final basePos = _getBasePosition(spot);

        // Calculate score for all available players
        final List<MapEntry<PesPlayer, int>> scoredPlayers = players
            .where((p) => !usedIds.contains(p.id))
            .map((p) => MapEntry(p, _calculateScore(p, basePos)))
            .toList();

        // Sort by score descending
        scoredPlayers.sort((a, b) => b.value.compareTo(a.value));

        if (scoredPlayers.isNotEmpty && scoredPlayers.first.value > -500) {
          final bestMatch = scoredPlayers.first.key;
          newSquad[spot] = bestMatch;
          usedIds.add(bestMatch.id);
        }
      }

      setState(() {
        _squad = newSquad;
        _isSearching = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eng kuchli tarkib avtomatik yig\'ildi! ⚡'),
            backgroundColor: Colors.blueAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _captureAndSave() async {
    try {
      final RenderRepaintBoundary boundary = _pitchBoundaryKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;

      // Ultra-HD capture: Use 3x device pixel ratio for maximum sharpness
      // This ensures crystal-clear screenshots even on high-DPI displays
      final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      final double capturePixelRatio =
          devicePixelRatio * 3.0; // 3x multiplier for ultra-HD

      // Capture image at ultra-high resolution
      final ui.Image image =
          await boundary.toImage(pixelRatio: capturePixelRatio);

      // Convert to PNG with lossless compression (maximum quality)
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      final Uint8List? bytes = byteData?.buffer.asUint8List();

      if (bytes != null) {
        // Navigate to preview screen
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ImagePreviewScreen(imageBytes: bytes),
            ),
          );
        }
      } else {
        // Error handling
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Rasmga olishda xato yuz berdi."),
                backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      // Catch any errors during capture
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xatolik: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  int _calculateScore(PesPlayer p, String spotPos) {
    int score = 0;
    final style = p.playingStyle ?? '';
    final pos = p.position;

    // RULE 1: STRICT GK SEPARATION
    if (spotPos == 'GK') return pos == 'GK' ? 1000 : -1000;
    if (pos == 'GK') return -1000;

    // RULE 2: POSITION MATCH
    if (pos == spotPos) score += 100;

    // RULE 3: PLAYING STYLE MATCH (THE BRAIN)
    switch (spotPos) {
      case 'CF':
        if (style == 'Goal Poacher') score += 200;
        if (style == 'Fox in the Box') score += 180;
        if (style == 'Deep-Lying Forward') score += 150;
        if (style == 'Target Man') score += 150;
        if (pos == 'SS') score += 50;
        break;
      case 'LWF':
      case 'RWF':
        if (style == 'Prolific Winger') score += 200;
        if (style == 'Roaming Flank') score += 180;
        if (style == 'Creative Playmaker') score += 100;
        break;
      case 'AMF':
        if (style == 'Hole Player') score += 200;
        if (style == 'Creative Playmaker') score += 180;
        if (style == 'Classic No. 10') score += 120;
        break;
      case 'CMF':
        if (style == 'Box-to-Box') score += 200;
        if (style == 'Orchestrator') score += 180;
        if (style == 'Hole Player') score += 100;
        break;
      case 'DMF':
        if (style == 'Anchorman') score += 250;
        if (style == 'Destroyer') score += 180;
        if (style == 'Orchestrator') score += 150;
        break;
      case 'CB':
        if (style == 'Build Up') score += 200;
        if (style == 'Destroyer') score += 180;
        if (style == 'Extra Frontman') score += 150;
        break;
      case 'LB':
      case 'RB':
        if (style == 'Offensive Full-back') score += 200;
        if (style == 'Defensive Full-back') score += 200;
        if (style == 'Full-back Finisher') score += 150;
        break;
    }

    // RULE 4: OVR BONUS (TIE BREAKER)
    score += int.tryParse(p.ovr) ?? 0;

    return score;
  }

  String _getBasePosition(String spot) {
    final pos = spot.replaceAll(RegExp(r'\d'), '');
    if (pos == 'LCB' || pos == 'RCB' || pos == 'CBF') return 'CB';
    if (pos == 'LCF' || pos == 'RCF') return 'CF';
    if (pos == 'LCM' || pos == 'RCM' || pos == 'CCM') return 'CMF';
    if (pos == 'LDMF' || pos == 'RDMF') return 'DMF';
    if (pos == 'LAMF' || pos == 'RAMF' || pos == 'CAM') return 'AMF';
    if (pos == 'LWB') return 'LB';
    if (pos == 'RWB') return 'RB';
    if (pos == 'CDM') return 'DMF';
    return pos;
  }

  /// TeamBuilder uchun ichki formation ma'lumotlari
  List<SquadFormation> _getBuiltInFormations() {
    return [
      // 4-3-3 - Classic Attacking
      SquadFormation(name: '4-3-3', positions: {
        'GK': const Offset(0.50, 0.94),
        'LB': const Offset(0.12, 0.82),
        'CB1': const Offset(0.35, 0.82),
        'CB2': const Offset(0.65, 0.82),
        'RB': const Offset(0.88, 0.82),
        'DMF': const Offset(0.50, 0.68),
        'CMF1': const Offset(0.32, 0.50),
        'CMF2': const Offset(0.68, 0.50),
        'LWF': const Offset(0.15, 0.18),
        'RWF': const Offset(0.85, 0.18),
        'CF': const Offset(0.50, 0.18),
      }),

      // 4-4-2 - Balanced
      SquadFormation(name: '4-4-2', positions: {
        'GK': const Offset(0.50, 0.94),
        'LB': const Offset(0.12, 0.82),
        'CB1': const Offset(0.35, 0.82),
        'CB2': const Offset(0.65, 0.82),
        'RB': const Offset(0.88, 0.82),
        'LMF': const Offset(0.15, 0.50),
        'LCM': const Offset(0.38, 0.50),
        'RCM': const Offset(0.62, 0.50),
        'RMF': const Offset(0.85, 0.50),
        'CF1': const Offset(0.38, 0.18),
        'CF2': const Offset(0.62, 0.18),
      }),

      // 4-2-1-3 - CAM Focus
      SquadFormation(name: '4-2-1-3', positions: {
        'GK': const Offset(0.50, 0.94),
        'LB': const Offset(0.12, 0.82),
        'CB1': const Offset(0.35, 0.82),
        'CB2': const Offset(0.65, 0.82),
        'RB': const Offset(0.88, 0.82),
        'DMF1': const Offset(0.35, 0.68),
        'DMF2': const Offset(0.65, 0.68),
        'AMF': const Offset(0.50, 0.35),
        'LWF': const Offset(0.15, 0.18),
        'RWF': const Offset(0.85, 0.18),
        'CF': const Offset(0.50, 0.18),
      }),

      // 4-3-1-2 - Diamond Midfield
      SquadFormation(name: '4-3-1-2', positions: {
        'GK': const Offset(0.50, 0.94),
        'LB': const Offset(0.12, 0.82),
        'CB1': const Offset(0.35, 0.82),
        'CB2': const Offset(0.65, 0.82),
        'RB': const Offset(0.88, 0.82),
        'LCM': const Offset(0.32, 0.50),
        'CDM': const Offset(0.50, 0.68),
        'RCM': const Offset(0.68, 0.50),
        'AMF': const Offset(0.50, 0.35),
        'CF1': const Offset(0.38, 0.18),
        'CF2': const Offset(0.62, 0.18),
      }),

      // 5-3-2 - Defensive Solid
      SquadFormation(name: '5-3-2', positions: {
        'GK': const Offset(0.50, 0.94),
        'LWB': const Offset(0.12, 0.82),
        'CB1': const Offset(0.32, 0.82),
        'CB2': const Offset(0.50, 0.82),
        'CB3': const Offset(0.68, 0.82),
        'RWB': const Offset(0.88, 0.82),
        'CMF1': const Offset(0.30, 0.50),
        'CMF2': const Offset(0.50, 0.50),
        'CMF3': const Offset(0.70, 0.50),
        'CF1': const Offset(0.40, 0.18),
        'CF2': const Offset(0.60, 0.18),
      }),

      // 4-2-2-2 - Box Midfield
      SquadFormation(name: '4-2-2-2', positions: {
        'GK': const Offset(0.50, 0.94),
        'LB': const Offset(0.12, 0.82),
        'CB1': const Offset(0.35, 0.82),
        'CB2': const Offset(0.65, 0.82),
        'RB': const Offset(0.88, 0.82),
        'DMF1': const Offset(0.35, 0.68),
        'DMF2': const Offset(0.65, 0.68),
        'AMF1': const Offset(0.35, 0.35),
        'AMF2': const Offset(0.65, 0.35),
        'CF1': const Offset(0.40, 0.18),
        'CF2': const Offset(0.60, 0.18),
      }),

      // 5-2-1-2 - Wing Back Attack
      SquadFormation(name: '5-2-1-2', positions: {
        'GK': const Offset(0.50, 0.94),
        'LWB': const Offset(0.12, 0.82),
        'CB1': const Offset(0.32, 0.82),
        'CB2': const Offset(0.50, 0.82),
        'CB3': const Offset(0.68, 0.82),
        'RWB': const Offset(0.88, 0.82),
        'DMF1': const Offset(0.35, 0.68),
        'DMF2': const Offset(0.65, 0.68),
        'AMF': const Offset(0.50, 0.35),
        'CF1': const Offset(0.40, 0.18),
        'CF2': const Offset(0.60, 0.18),
      }),

      // 4-2-4 - Ultra Attack
      SquadFormation(name: '4-2-4', positions: {
        'GK': const Offset(0.50, 0.94),
        'LB': const Offset(0.12, 0.82),
        'CB1': const Offset(0.35, 0.82),
        'CB2': const Offset(0.65, 0.82),
        'RB': const Offset(0.88, 0.82),
        'CMF1': const Offset(0.38, 0.50),
        'CMF2': const Offset(0.62, 0.50),
        'LWF': const Offset(0.15, 0.18),
        'LCF': const Offset(0.38, 0.18),
        'RCF': const Offset(0.62, 0.18),
        'RWF': const Offset(0.85, 0.18),
      }),

      // 3-5-2 - Wing Domination
      SquadFormation(name: '3-5-2', positions: {
        'GK': const Offset(0.50, 0.94),
        'CB1': const Offset(0.28, 0.82),
        'CB2': const Offset(0.50, 0.82),
        'CB3': const Offset(0.72, 0.82),
        'LMF': const Offset(0.12, 0.52),
        'LCM': const Offset(0.38, 0.62),
        'RCM': const Offset(0.62, 0.62),
        'RMF': const Offset(0.88, 0.52),
        'LWF': const Offset(0.18, 0.28),
        'CF': const Offset(0.50, 0.18),
        'RWF': const Offset(0.82, 0.28),
      }),

      // 3-2-4-1 - Midfield Dominant
      SquadFormation(name: '3-2-4-1', positions: {
        'GK': const Offset(0.50, 0.94),
        'CB1': const Offset(0.28, 0.82),
        'CB2': const Offset(0.50, 0.82),
        'CB3': const Offset(0.72, 0.82),
        'DMF1': const Offset(0.35, 0.65),
        'DMF2': const Offset(0.65, 0.65),
        'LMF': const Offset(0.12, 0.45),
        'AMF1': const Offset(0.38, 0.45),
        'AMF2': const Offset(0.62, 0.45),
        'RMF': const Offset(0.88, 0.45),
        'CF': const Offset(0.50, 0.18),
      }),

      // 3-2-3-2 - High Press
      SquadFormation(name: '3-2-3-2', positions: {
        'GK': const Offset(0.50, 0.94),
        'CB1': const Offset(0.28, 0.82),
        'CB2': const Offset(0.50, 0.82),
        'CB3': const Offset(0.72, 0.82),
        'DMF1': const Offset(0.35, 0.65),
        'DMF2': const Offset(0.65, 0.65),
        'LMF': const Offset(0.15, 0.42),
        'AMF': const Offset(0.50, 0.38),
        'RMF': const Offset(0.85, 0.42),
        'CF1': const Offset(0.38, 0.18),
        'CF2': const Offset(0.62, 0.18),
      }),
    ];
  }

  void _initializeSquad() {
    _squad = {for (var pos in _currentFormation.positions.keys) pos: null};
  }

  Future<void> _loadSavedSquad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString('saved_squad_data');
      if (savedStr != null) {
        final data = jsonDecode(savedStr);
        final formationName = data['formationName'];
        final foundFormation = _formations.firstWhere(
          (f) => f.name == formationName,
          orElse: () => _formations.first,
        );

        setState(() {
          _currentFormation = foundFormation;
          // Note: In a real app, you'd fetch player details by ID here.
          // For now, we'll just keep the structure if we have objects stored.
          // Since we ideally save just IDs, this part might need a list of players.
          // But for this session, we'll persist the names/ids if they were available.
        });
      }
    } catch (e) {
      debugPrint('Error loading saved squad: $e');
    }
  }

  Future<void> _saveSquad() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'formationName': _currentFormation.name,
      'players': _squad.map((k, v) => MapEntry(k, v?.id)),
    };
    await prefs.setString('saved_squad_data', jsonEncode(data));

    // Trigger export based on platform as requested by user
    await _shareSquad();
  }

  void _changeFormation(SquadFormation formation) {
    setState(() {
      _currentFormation = formation;
      Map<String, PesPlayer?> newSquad = {
        for (var pos in formation.positions.keys) pos: null
      };
      // Migrate existing players if position names match
      _squad.forEach((key, value) {
        if (newSquad.containsKey(key)) {
          newSquad[key] = value;
        }
      });
      _squad = newSquad;
    });
  }

  double get _averageOvr {
    List<PesPlayer> active = _squad.values.whereType<PesPlayer>().toList();
    if (active.isEmpty) return 0;

    double total = 0;
    for (var p in active) {
      double ovr = double.tryParse(p.ovr) ?? 0;
      if (ovr == 0) ovr = 90; // Default fallback for UI
      total += ovr;
    }
    return total / active.length;
  }

  double get _chemistry {
    List<PesPlayer> active = _squad.values.whereType<PesPlayer>().toList();
    if (active.length < 2) return 0;

    int points = 0;
    for (int i = 0; i < active.length; i++) {
      for (int j = i + 1; j < active.length; j++) {
        if (active[i].club == active[j].club && active[i].club != 'Free Agent')
          points += 10;
        if (active[i].nationality == active[j].nationality) points += 5;
      }
    }

    double maxPossible = (active.length * (active.length - 1) / 2) * 15;
    if (maxPossible == 0) return 0;
    double score = (points / (active.length * 5)) * 10; // Normalized for UI
    return score.clamp(0, 100);
  }

  Future<void> _searchPlayers(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);
    try {
      final results = await _pesService.fetchPlayers(
          filters: {'name': query, 'all': '1', 'mode': 'max_level'});
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  void _addPlayerToSpot(String spot, PesPlayer player) {
    setState(() {
      _squad[spot] = player;
      _selectedSpot = null;
      _searchResults = [];
      _searchController.clear();
    });
  }

  Future<void> _shareSquad() async {
    final bytes = await _screenshotController.capture();
    if (bytes == null) return;

    if (kIsWeb) {
      // Web platform handling
      try {
        if (PlatformUtils.isTelegramWebApp()) {
          // Send to Telegram bot
          final base64Image = base64Encode(bytes);
          final data = jsonEncode({
            'type': 'squad_screenshot',
            'image': base64Image,
            'formation': _currentFormation.name,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
          PlatformUtils.sendTelegramData(data);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Squad sent to Telegram bot! 🚀'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Regular web - download as blob
          await PlatformUtils.downloadBlob(
              bytes, 'mysquad_${DateTime.now().millisecondsSinceEpoch}.png');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Squad downloaded! 📥'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error sharing: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Mobile platform - use native share
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/mysquad_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await File(path).create();
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(path)],
          text:
              'Check out my eFootball Squad Build! 🔥 #eFootball #SuperSquad');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pitchHeight = size.height * 0.65;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('SuperSquad Builder',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        actions: [
          // IconButton(
          //     icon: const Icon(Icons.auto_fix_high_rounded,
          //         color: Colors.cyanAccent),
          //     onPressed: _autoPick,
          //     tooltip: 'Auto Pick'),
          // IconButton(
          //     icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
          //     onPressed: _showFormationDialog,
          //     tooltip: 'Change Formation'),
          // IconButton(
          //     icon: const Icon(Icons.share_outlined, color: AppColors.accent),
          //     onPressed: _shareSquad),
          IconButton(
              icon: const Icon(Icons.save_alt_rounded, color: Colors.white70),
              onPressed: _captureAndSave),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildStatsHeader(),
          Expanded(
            child: Stack(
              children: [
                _buildPitch(pitchHeight),
                _buildFormationFab(),
                if (_selectedSpot != null) _buildSearchOverlay(),
                if (_isSearching && _selectedSpot == null)
                  _buildAutoPickOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // _statItem('Avg OVR', _averageOvr.toInt().toString(), Icons.bolt,
          //     Colors.amber),
          _statItem('Chemistry', '${_chemistry.toInt()}', Icons.auto_awesome,
              Colors.cyanAccent),
          GestureDetector(
            onLongPress: _showFormationDialog,
            onTap: _showFormationDialog,
            child: _statItem('Formation', _currentFormation.name,
                Icons.grid_view_rounded, Colors.purpleAccent),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(value,
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Text(label,
            style: GoogleFonts.outfit(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPitch(double height) {
    return LayoutBuilder(builder: (context, constraints) {
      // Get formation rows from bottom to top (GK first, attackers last)
      final rows = _getFormationRowsSimple();
      final totalRows = rows.length;

      // Adaptive scaling based on number of rows
      double scale = 1.0;
      if (totalRows > 5)
        scale = 0.82;
      else if (totalRows > 4) scale = 0.9;

      return Center(
        child: AspectRatio(
          aspectRatio: 0.72, // Locked aspect ratio (width:height)
          child: RepaintBoundary(
            key: _pitchBoundaryKey,
            child: WidgetsToImage(
              controller: _screenshotController,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: -5,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      CustomPaint(size: Size.infinite, painter: PitchPainter()),

                      // Formation Info Stamp
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Opacity(
                          opacity: 0.2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'FORMATION',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _currentFormation.name,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Simple row-based layout: bottom (GK) to top (Attackers)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: rows.reversed.map((rowSpots) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: rowSpots
                                  .map((spot) =>
                                      _buildPlayerCardSpot(spot, scale))
                                  .toList(),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Smart formation row grouping based on Y-coordinate proximity
  /// Players are grouped into rows and sorted left-to-right within each row
  List<List<String>> _getFormationRowsSimple() {
    final positions = _currentFormation.positions;

    // Group players by Y-coordinate proximity (threshold 0.06 for same row)
    Map<double, List<String>> rowsMap = {};

    for (var entry in positions.entries) {
      double dy = entry.value.dy;

      // Find existing row within threshold
      double? matchingRow;
      for (var existingY in rowsMap.keys) {
        if ((existingY - dy).abs() < 0.06) {
          matchingRow = existingY;
          break;
        }
      }

      if (matchingRow != null) {
        rowsMap[matchingRow]!.add(entry.key);
      } else {
        rowsMap[dy] = [entry.key];
      }
    }

    // Sort rows from bottom to top (GK to attackers)
    var sortedYs = rowsMap.keys.toList()..sort((a, b) => b.compareTo(a));

    // Create final row list with players sorted left-to-right
    List<List<String>> rows = [];
    for (var y in sortedYs) {
      var playersInRow = rowsMap[y]!;

      // Sort players in this row by X-coordinate (left to right)
      playersInRow.sort((a, b) {
        double xA = positions[a]?.dx ?? 0;
        double xB = positions[b]?.dx ?? 0;
        return xA.compareTo(xB);
      });

      rows.add(playersInRow);
    }

    return rows;
  }

  Widget _buildPlayerCardSpot(String spotName, double scale) {
    final player = _squad[spotName];
    final ovrValue = player != null ? (int.tryParse(player.ovr) ?? 0) : 0;
    final posLabel = spotName.replaceAll(RegExp(r'\d'), '');

    Color badgeColor = Colors.grey;
    if (ovrValue >= 95)
      badgeColor = const Color(0xFFFFD700);
    else if (ovrValue >= 90)
      badgeColor = const Color(0xFFC084FC);
    else if (ovrValue >= 85)
      badgeColor = const Color(0xFF4ADE80);
    else if (ovrValue >= 80)
      badgeColor = const Color(0xFF38BDF8);
    else if (ovrValue > 0) badgeColor = Colors.white;

    final cardWidth = 60.0 * scale;
    final cardHeight = 82.0 * scale;

    return DragTarget<PesPlayer>(
      onAcceptWithDetails: (details) =>
          _addPlayerToSpot(spotName, details.data),
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onLongPress: () {
            if (player != null) setState(() => _squad[spotName] = null);
          },
          onTap: () => setState(() => _selectedSpot = spotName),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: player != null
                        ? Colors.white.withOpacity(0.8)
                        : Colors.white.withOpacity(0.12),
                    width: player != null ? 1.5 : 1,
                  ),
                ),
                child: player != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CachedNetworkImage(
                              imageUrl: kIsWeb
                                  ? 'https://corsproxy.io/?${Uri.encodeComponent(player.imageUrl)}'
                                  : player.imageUrl,
                              httpHeaders: PesService.headers,
                              fit: BoxFit.cover, // Cover for better fill
                              width: cardWidth,
                              height: cardHeight,
                              // High quality rendering
                              filterQuality: FilterQuality.high,
                              // High-res in-memory cache for crisp display
                              memCacheWidth: (cardWidth * 3).toInt(),
                              memCacheHeight: (cardHeight * 3).toInt(),
                              // Smooth fade-in
                              fadeInDuration: const Duration(milliseconds: 200),
                              placeholder: (context, url) => Container(
                                color: Colors.white10,
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white24,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.white10,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white24,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          // Rating Badge
                          // Positioned(
                          //   top: 2,
                          //   right: 2,
                          //   child: Container(
                          //     padding: const EdgeInsets.symmetric(
                          //         horizontal: 4, vertical: 0.5),
                          //     decoration: BoxDecoration(
                          //       color: badgeColor,
                          //       borderRadius: BorderRadius.circular(2),
                          //     ),
                          //     child: Text(
                          //       player.ovr,
                          //       style: GoogleFonts.outfit(
                          //         color: Colors.black,
                          //         fontSize: 8.5 * scale,
                          //         fontWeight: FontWeight.w900,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Position Overlay
                          Positioned(
                            bottom: 2,
                            left: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                posLabel,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 7 * scale,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded,
                                color: Colors.white.withOpacity(0.2),
                                size: 20 * scale),
                            Text(
                              posLabel,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.15),
                                  fontSize: 9 * scale,
                                  fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: cardWidth + 10,
                child: Text(
                  player?.name.split(' ').last ?? '',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(player != null ? 0.9 : 0.0),
                    fontSize: 8.5 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormationFab() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: FloatingActionButton.extended(
        onPressed: _showFormationDialog,
        backgroundColor: AppColors.accent,
        label: Text('Formation',
            style: GoogleFonts.outfit(
                color: Colors.black, fontWeight: FontWeight.bold)),
        icon:
            const Icon(Icons.dashboard_customize_rounded, color: Colors.black),
      ),
    );
  }

  void _showFormationDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.05),
                blurRadius: 40,
                spreadRadius: 10,
              )
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'TAKTKIK SXEMANI TANLANG',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Jamoangiz uchun eng mos variantni tanlang',
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _formations.length,
                  itemBuilder: (context, index) {
                    final f = _formations[index];
                    final isSelected = _currentFormation.name == f.name;
                    return GestureDetector(
                      onTap: () {
                        _changeFormation(f);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent.withOpacity(0.1)
                              : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color:
                                isSelected ? AppColors.accent : Colors.white10,
                            width: 2,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.15),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accent.withOpacity(0.1)
                                    : Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.grid_4x4_rounded,
                                color: isSelected
                                    ? AppColors.accent
                                    : Colors.white38,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              f.name,
                              style: GoogleFonts.outfit(
                                color: isSelected
                                    ? AppColors.accent
                                    : Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${f.positions.length} o\'yinchi',
                              style: GoogleFonts.outfit(
                                color: Colors.white24,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchOverlay() {
    return Positioned.fill(
      child: FadeTransition(
        opacity: const AlwaysStoppedAnimation(1),
        child: Container(
          color: Colors.black.withOpacity(0.95),
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 28),
                    onPressed: () => setState(() => _selectedSpot = null)),
                title: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText:
                        ' $_selectedSpot pozitsiyadagi o\'yinchi ismini yozing...',
                    hintStyle: const TextStyle(color: Colors.white24),
                    border: InputBorder.none,
                  ),
                  onSubmitted: _searchPlayers,
                ),
                actions: [
                  if (_isSearching)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.accent))))
                  else
                    IconButton(
                        icon: const Icon(Icons.search_rounded,
                            color: AppColors.accent),
                        onPressed: () =>
                            _searchPlayers(_searchController.text)),
                ],
              ),
              Expanded(
                child: _searchResults.isEmpty && !_isSearching
                    ? Center(
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sports_soccer_rounded,
                              size: 80, color: Colors.white10),
                          const SizedBox(height: 20),
                          Text('Build your dream team...',
                              style: GoogleFonts.outfit(
                                  color: Colors.white24, fontSize: 18)),
                        ],
                      ))
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemBuilder: (context, index) {
                          final p = _searchResults[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: kIsWeb
                                        ? 'https://corsproxy.io/?${Uri.encodeComponent(p.imageUrl)}'
                                        : p.imageUrl,
                                    httpHeaders: PesService.headers,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.person,
                                            color: Colors.white24),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name,
                                          style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${p.position} • ${p.club} • ${p.nationality}',
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12)),
                                      const SizedBox(height: 2),
                                      Text('OVR: ${p.ovr}',
                                          style: TextStyle(
                                              color: AppColors.accent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                  ),
                                  onPressed: () =>
                                      _addPlayerToSpot(_selectedSpot!, p),
                                  child: const Text('ADD',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutoPickOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.accent),
              const SizedBox(height: 24),
              Text(
                'ENG KUCHLI TARKIB\nYIG\'ILMOQDA...',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu biroz vaqt olishi mumkin',
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
