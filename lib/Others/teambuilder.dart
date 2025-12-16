import 'package:efinfo_beta/Others/imageSaver.dart'; // Yordamchi fayl
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/Others/pitchpainter.dart'; // Yordamchi fayl
import 'package:efinfo_beta/models/teamBLDRModel.dart'; // Model fayli
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

// JSON dan ma'lumotlarni yuklash uchun
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../additional/imageview.dart';

// ---------------------------------------------------------
// 2. ASOSIY EKRAN (TEAM BUILDER)
// ---------------------------------------------------------

class TeamBuilderScreen extends StatefulWidget {
  const TeamBuilderScreen({super.key});

  @override
  State<TeamBuilderScreen> createState() => _TeamBuilderScreenState();
}

class _TeamBuilderScreenState extends State<TeamBuilderScreen> {
  // RepaintBoundary ni boshqarish uchun Global Key
  final GlobalKey _pitchBoundaryKey = GlobalKey();
  final WidgetsToImageController _controller = WidgetsToImageController();

  String selectedFormation = '4-3-3';
  Map<String, TBuilderPlayer?> fieldPositions = {};
  String selectedFilter = 'All';
  final TextEditingController searchController = TextEditingController();

  // YANGI: O'yinchilar ro'yxati va Yuklash holati
  List<TBuilderPlayer> _allPlayers = [];
  bool _isLoading = true;

  final Map<String, List<String>> roleMap = {
    'Goalkeeper': ['GK'],
    'Defense': ['CB', 'LB', 'RB'],
    'Midfield': ['CMF', 'DMF', 'AMF', 'LMF', 'RMF'],
    'Forward': ['CF', 'SS', 'LWF', 'RWF'],
  };

  final Map<String, Map<String, Alignment>> formations = {
    '4-3-3': {
      'GK': const Alignment(0.0, 0.95),
      'LB': const Alignment(-0.9, 0.7),
      'CB1': const Alignment(-0.4, 0.8),
      'CB2': const Alignment(0.4, 0.8),
      'RB': const Alignment(0.9, 0.7),
      'CM1': const Alignment(-0.7, 0.15),
      'DMF': const Alignment(0.0, 0.4),
      'CM2': const Alignment(0.7, 0.15),
      'LWF': const Alignment(-0.65, -0.74),
      'CF': const Alignment(0.0, -0.75),
      'RWF': const Alignment(0.65, -0.74),
    },
    '4-4-2': {
      'GK': const Alignment(0.0, 0.95),
      'LB': const Alignment(-0.9, 0.75),
      'CB1': const Alignment(-0.4, 0.85),
      'CB2': const Alignment(0.4, 0.85),
      'RB': const Alignment(0.9, 0.75),
      'LMF': const Alignment(-0.9, 0.15),
      'CM1': const Alignment(-0.35, 0.3),
      'CM2': const Alignment(0.35, 0.3),
      'RMF': const Alignment(0.9, 0.15),
      'CF1': const Alignment(-0.35, -0.6),
      'CF2': const Alignment(0.35, -0.6),
    },
  };

  @override
  void initState() {
    super.initState();
    _loadPlayers(); // O'yinchilarni JSON dan yuklash
    searchController.addListener(() => setState(() {}));
  }

  // ---------------------------------------------------------
  // JSON DAN MA'LUMOT YUKLASH MANTIQI (Yangi)
  // ---------------------------------------------------------

  Future<void> _loadPlayers() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/players.json');
      final List<dynamic> data = json.decode(response);
      final List<TBuilderPlayer> loadedPlayers = data
          .map((json) => TBuilderPlayer.fromJson(json as Map<String, dynamic>))
          .toList();

      setState(() {
        _allPlayers = loadedPlayers;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error loading players from JSON: $e");
      }
    }
  }

  // ---------------------------------------------------------
  // SCREENSHOT MANTIQI
  // ---------------------------------------------------------

  Future<void> _captureAndSave() async {
    final RenderRepaintBoundary boundary = _pitchBoundaryKey.currentContext!
        .findRenderObject()! as RenderRepaintBoundary;

    final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    final Uint8List? bytes = byteData?.buffer.asUint8List();

    if (bytes != null) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(imageBytes: bytes),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Rasmga olishda xato yuz berdi."),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  bool _playerMatchesFilter(TBuilderPlayer player) {
    if (selectedFilter == 'All') return true;
    final allowedPositions = roleMap[selectedFilter] ?? [];
    return allowedPositions.contains(player.position);
  }

  bool canAcceptPlayer(TBuilderPlayer player, String slotKey) {
    if (slotKey.startsWith('GK') && player.position != 'GK') return false;
    if (!slotKey.startsWith('GK') && player.position == 'GK') return false;
    return true;
  }

  void _movePlayer(TBuilderPlayer player, String newSlotKey) {
    final oldSlotKey = fieldPositions.entries
        .firstWhere((entry) => entry.value?.id == player.id,
            orElse: () => const MapEntry('', null))
        .key;

    setState(() {
      if (oldSlotKey.isNotEmpty) {
        fieldPositions.remove(oldSlotKey);
      }
      fieldPositions[newSlotKey] = player;
    });
  }

  void _removePlayerFromPitch(TBuilderPlayer player) {
    final slotToRemove = fieldPositions.entries
        .firstWhere((entry) => entry.value?.id == player.id,
            orElse: () => const MapEntry('', null))
        .key;

    if (slotToRemove.isNotEmpty) {
      setState(() {
        fieldPositions.remove(slotToRemove);
      });
    }
  }

  List<TBuilderPlayer> get _filteredAndUnusedPlayers {
    // Ma'lumot manbasi endi _allPlayers
    final allPlayers = _allPlayers;
    final playersOnPitchIds = fieldPositions.values
        .whereType<TBuilderPlayer>()
        .map((p) => p.id)
        .toSet();
    final search = searchController.text.toLowerCase();

    return allPlayers.where((player) {
      if (playersOnPitchIds.contains(player.id)) {
        return false;
      }
      if (!_playerMatchesFilter(player)) {
        return false;
      }
      if (search.isNotEmpty && !player.name.toLowerCase().contains(search)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF011A0B), // HomePage foni
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                  color: Color(0xFF06DF5D)), // HomePage accent
              SizedBox(height: 20),
              Text("O'yinchilar ma'lumotlari yuklanmoqda...",
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    final currentFormation = formations[selectedFormation]!;

    return Scaffold(
      backgroundColor: AppColors.background, // HomePage foni
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: AppColors.background, // AppBar foni ham bir xil
        elevation: 0,
        title: const Text("SuperSquad XI",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: AppColors.background,
              value: selectedFormation,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.accent), // Accent
              style: const TextStyle(
                  color: AppColors.accent, fontWeight: FontWeight.bold),
              items: formations.keys
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) => setState(() {
                selectedFormation = v!;
                fieldPositions.clear();
              }),
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _captureAndSave,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent, // Accent
                  foregroundColor: Colors.black), // Matn qora
              child: const Text("Saqlash",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // --- 1. FUTBOL MAYDONI (Yuqori qism) ---
          Expanded(
            flex: 6,
            child: RepaintBoundary(
              key: _pitchBoundaryKey,
              child: WidgetsToImage(
                controller: _controller,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: CustomPaint(
                    painter: PitchPainter(),
                    child: Stack(
                      children: [
                        // A) O'chirish/Qaytarish zonasi
                        Align(
                          alignment: Alignment.topCenter,
                          child: DragTarget<TBuilderPlayer>(
                            onAcceptWithDetails: (details) {
                              _removePlayerFromPitch(details.data);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("O'yinchi Grid'ga qaytarildi!"),
                                    backgroundColor: Colors.amber),
                              );
                            },
                            builder: (context, candidate, rejected) {
                              if (candidate.isNotEmpty) {
                                return Container(
                                  height: 60,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.delete_forever,
                                      color: Colors.white, size: 40),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),

                        // B) Pozitsiya katakchalari
                        ...currentFormation.entries.map((entry) {
                          final slotKey = entry.key;
                          final alignment = entry.value;

                          return Align(
                            alignment: alignment,
                            child: DragTarget<TBuilderPlayer>(
                              onAcceptWithDetails: (details) {
                                final TBuilderPlayer player = details.data;

                                if (canAcceptPlayer(player, slotKey)) {
                                  _movePlayer(player, slotKey);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Darvozabon faqat darvozaga!"),
                                        backgroundColor: Colors.red),
                                  );
                                }
                              },
                              builder: (context, candidate, rejected) {
                                final player = fieldPositions[slotKey];
                                final isHovered = candidate.isNotEmpty;

                                return SizedBox(
                                  width: 50,
                                  height: 60,
                                  child: player != null
                                      ? _buildPlacedPlayer(player, slotKey)
                                      : _buildEmptySlot(slotKey, isHovered),
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- 2. O'YINCHILAR PANELI (Pastki qism) ---
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color:
                    const Color(0xFF011A0B).withOpacity(0.8), // Biroz shaffof
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                    color: const Color(0xFF06DF5D).withOpacity(0.3), width: 1),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, -4))
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "O'yinchini maydondan olib tashlash uchun ustiga bir marta bosing!",
                    style: TextStyle(color: Colors.red, fontSize: 10),
                  ),
                  const SizedBox(height: 10),
                  // A) Filtrlar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 0.0,
                      children: [
                        'All',
                        'Goalkeeper',
                        'Defense',
                        'Midfield',
                        'Forward'
                      ].map((filter) {
                        final isSelected = selectedFilter == filter;
                        return FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (val) =>
                              setState(() => selectedFilter = filter),
                          backgroundColor: Colors.white10,
                          selectedColor: AppColors.accent,
                          checkmarkColor: Colors.black,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFF06DF5D)
                                      : Colors.white24)),
                        );
                      }).toList(),
                    ),
                  ),

                  // B) Qidiruv
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "O'yinchi qidiring...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.white54), // Grey o'rniga
                        filled: true,
                        fillColor: Colors.white10, // Black26 o'rniga
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(color: Colors.white24)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                                color: AppColors.accent)), // Accent
                      ),
                      // onChanged allaqachon initState() da o'rnatilgan
                    ),
                  ),

                  // C) O'yinchilar Grid'i
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _filteredAndUnusedPlayers.length,
                      itemBuilder: (ctx, i) {
                        final player = _filteredAndUnusedPlayers[i];

                        return LongPressDraggable<TBuilderPlayer>(
                          data: player,
                          feedback: SizedBox(
                            width: 80,
                            height: 100,
                            child: Material(
                              color: Colors.transparent,
                              child: _buildPlayerCard(player,
                                  scale: 1.1, showDetails: true),
                            ),
                          ),
                          childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: _buildPlayerCard(player,
                                  scale: 0.9, showDetails: false)),
                          child: _buildPlayerCard(player, showDetails: false),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETLAR ---

  Widget _buildEmptySlot(String title, bool isHovered) {
    return Container(
      decoration: BoxDecoration(
        color: isHovered ? AppColors.accent.withOpacity(0.3) : Colors.black38,
        border: Border.all(
            color: isHovered ? AppColors.accent : Colors.white24, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const Icon(Icons.add, color: Colors.white30, size: 18),
        ],
      ),
    );
  }

  Widget _buildPlacedPlayer(TBuilderPlayer player, String slotKey) {
    return LongPressDraggable<TBuilderPlayer>(
      data: player,
      feedback: SizedBox(
        width: 80,
        height: 100,
        child: Material(
          color: Colors.transparent,
          child: _buildPlayerCard(player, scale: 1.1, showDetails: true),
        ),
      ),
      childWhenDragging: Opacity(
          opacity: 0.3, child: _buildPlayerCard(player, showDetails: true)),
      child: GestureDetector(
        onTap: () {
          _removePlayerFromPitch(player);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${player.name} maydondan olib tashlandi."),
              backgroundColor: Colors.redAccent,
            ),
          );
        },
        child: _buildPlayerCard(player,
            showDetails: true), // Pitchda ism va pozitsiya ko'rinsin
      ),
    );
  }

  // Player Card WIDGETI
  Widget _buildPlayerCard(TBuilderPlayer player,
      {double scale = 1.0, required bool showDetails}) {
    return Transform.scale(
      scale: scale,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // 1. Watermark / Orqa fon (O'yinchi rasmi)
              Container(
                width: 60,
                height: 70,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black54,
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ],
                ),
                child: buildPlayerImage(player.imageUrl),
              ),

              // 2. Rating (OVR)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Text(
                    '${player.rating}',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 10),
                  ),
                ),
              ),
              // 3. Pozitsiya (Pitch ustida)
              Positioned(
                top: 20,
                right: 2,
                child: Text(
                  player.position,
                  style: const TextStyle(
                      color: AppColors.accent, // Cyan o'rniga
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // 4. Ism (Faqat maydonda va feedbackda ko'rinadi)
          if (showDetails)
            Text(
              // player.name.split(' ').first,
              player.name,
              maxLines: 1,
              // overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 8),
            ),
        ],
      ),
    );
  }
}
