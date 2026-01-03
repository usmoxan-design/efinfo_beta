import 'dart:math';
import 'package:efinfo_beta/Pages/PackSettingsPage.dart';
import 'package:efinfo_beta/Pages/PackResultPage.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

import 'package:efinfo_beta/models/pack_player.dart';

class PackSimulatorPage extends StatefulWidget {
  const PackSimulatorPage({super.key});

  @override
  State<PackSimulatorPage> createState() => _PackSimulatorPageState();
}

class _PackSimulatorPageState extends State<PackSimulatorPage>
    with TickerProviderStateMixin {
  int coins = 2700;
  Map<String, List<PackPlayer>> pools = {};
  Map<String, Map<int, int>> initialRarityCounts = {};
  Map<String, List<PackPlayer>> history = {
    "50": [],
    "100": [],
    "150": [],
    "250": [],
  };

  late ConfettiController _confettiController;
  final Random _random = Random();

  bool isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _initializeAllPools();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isFirstLoad) {
        _showTutorial();
        isFirstLoad = false;
      }
    });
  }

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        title: Text("Pack Simulyatoriga xush kelibsiz!",
            style: GoogleFonts.outfit(color: Colors.white)),
        content: Text(
          "O'z omadingizni eFootball uslubidagi packlar bilan sinab ko'ring. Tangalar faqat demo uchun. Pack bo'shagan sari omad ehtimoli oshadi!",
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Boshladik!",
                style: GoogleFonts.outfit(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _initializeAllPools() {
    pools = {
      "50": _generatePool("50"),
      "100": _generatePool("100"),
      "150": _generatePool("150"),
      "250": _generatePool("250"),
    };
    // Initialize initial rarity counts
    pools.forEach((type, pool) {
      initialRarityCounts[type] = {
        5: pool.where((p) => p.stars == 5).length,
        4: pool.where((p) => p.stars == 4).length,
        3: pool.where((p) => p.stars == 3).length,
        2: pool.where((p) => p.stars <= 2).length,
      };
      history[type] = [];
    });
    setState(() {});
  }

  List<PackPlayer> _generatePool(String type) {
    List<PackPlayer> pool = [];
    int fiveStars = 0,
        fourStars = 0,
        threeStars = 0,
        twoStars = 0,
        oneStars = 0;

    switch (type) {
      case "50":
        fiveStars = 1;
        fourStars = 5;
        threeStars = 10;
        twoStars = 15;
        oneStars = 19;
        break;
      case "100":
        fiveStars = 4;
        fourStars = 6;
        threeStars = 10;
        twoStars = 20;
        oneStars = 60;
        break;
      case "150":
        fiveStars = 3;
        fourStars = 10;
        threeStars = 15;
        twoStars = 30;
        oneStars = 92;
        break;
      case "250":
        fiveStars = 6;
        fourStars = 15;
        threeStars = 25;
        twoStars = 50;
        oneStars = 154;
        break;
    }

    final positions = [
      "CF",
      "LWF",
      "RWF",
      "AMF",
      "CMF",
      "DMF",
      "CB",
      "LB",
      "RB",
      "GK"
    ];
    for (int i = 0; i < fiveStars; i++) {
      pool.add(PackPlayer(
          name: "Epic Player ${i + 1}",
          position: positions[_random.nextInt(positions.length)],
          stars: 5,
          rarity: "Epic Showtime"));
    }
    for (int i = 0; i < fourStars; i++) {
      pool.add(PackPlayer(
          name: "Highlight ${i + 1}",
          position: positions[_random.nextInt(positions.length)],
          stars: 4,
          rarity: "Highlight"));
    }
    for (int i = 0; i < threeStars; i++) {
      pool.add(PackPlayer(
          name: "Featured ${i + 1}",
          position: positions[_random.nextInt(positions.length)],
          stars: 3,
          rarity: "Featured"));
    }
    for (int i = 0; i < twoStars; i++) {
      pool.add(PackPlayer(
          name: "Standard A${i + 1}",
          position: positions[_random.nextInt(positions.length)],
          stars: 2,
          rarity: "Standard"));
    }
    for (int i = 0; i < oneStars; i++) {
      pool.add(PackPlayer(
          name: "Standard B${i + 1}",
          position: positions[_random.nextInt(positions.length)],
          stars: 1,
          rarity: "Ordinary"));
    }

    pool.shuffle(_random);
    return pool;
  }

  void _pull(String type, int count) {
    int cost = count == 1 ? 100 : 900;
    if (coins < cost) {
      _showAlert("Tangalar yetarli emas!",
          "Tangalarni to'ldirish uchun sozlamalarga o'ting.");
      return;
    }

    if (pools[type]!.length < count) {
      _showAlert("Pack tugadi!",
          "Ushbu packni qayta tiklash uchun asosiy reset tugmasini bosing.");
      return;
    }

    List<PackPlayer> pulled = [];
    for (int i = 0; i < count; i++) {
      pulled.add(pools[type]!.removeAt(0));
    }

    setState(() {
      coins -= cost;
      history[type]?.addAll(pulled);
    });

    int epicsCount = pulled.where((p) => p.stars == 5).length;

    if (epicsCount > 0) {
      _confettiController.play();
    }

    // Sort by stars before navigating
    pulled.sort((a, b) => b.stars.compareTo(a.stars));
    _navigateToResult(pulled);
  }

  void _confirmPull(String type, int count) {
    int cost = count == 1 ? 100 : 900;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        title: Text("Tasdiqlash",
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: Colors.white)),
        content: Text("$count ta packni $cost tangaga ochmoqchimisiz?",
            style: GoogleFonts.outfit(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Bekor qilish",
                style: GoogleFonts.outfit(color: Colors.redAccent)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _pull(type, count);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
            ),
            child: Text("Tasdiqlash",
                style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToResult(List<PackPlayer> players) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackResultPage(
          players: players,
          onDone: () {
            // Callback can be used for extra logic if needed
          },
        ),
      ),
    );
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: GoogleFonts.outfit()),
        content: Text(message, style: GoogleFonts.outfit()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  void _viewPackPlayers(String type, bool isDark) {
    List<PackPlayer> sortedPool = List.from(pools[type]!);
    sortedPool.sort((a, b) => b.stars.compareTo(a.stars));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text("$type talik Pack tarkibi",
                style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black)),
            Text("Qolgan o'yinchilar: ${pools[type]!.length}",
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 10),
            _buildRaritySummaryForList(pools[type]!, isDark),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8),
                itemCount: sortedPool.length,
                itemBuilder: (context, index) =>
                    _buildPlayerCard(sortedPool[index], mini: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewHistory(String type, bool isDark) {
    if (history[type]!.isEmpty) {
      _showAlert("Tarix bo'sh", "Siz hali bu packdan o'yinchi ochmadingiz.");
      return;
    }

    List<PackPlayer> sortedHistory = List.from(history[type]!);
    sortedHistory.sort((a, b) => b.stars.compareTo(a.stars));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2))),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text("Ochilgan o'yinchilar tarixi ($type)",
                style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.black : Colors.white)),
            const SizedBox(height: 10),
            _buildRaritySummaryForList(history[type]!, isDark),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8),
                itemCount: sortedHistory.length,
                itemBuilder: (context, index) =>
                    _buildPlayerCard(sortedHistory[index], mini: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor:
          isDark ? Color(0xFF000814) : const Color.fromARGB(255, 237, 237, 237),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text("Pack Simulyatori",
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: textColor)),
        actions: [
          _buildCoinDisplay(),
          IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PackSettingsPage(
                        currentCoins: coins,
                        onCoinsUpdated: (v) => setState(() => coins = v)))),
            icon: Icon(Icons.settings,
                color: isDark ? Colors.white : Colors.black),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                coins = 2700;
                _initializeAllPools();
              });
            },
            icon: Icon(Icons.refresh,
                color: isDark ? Colors.white : Colors.black),
            tooltip: "Hammasini qayta tiklash",
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildRNGInfoCard(isDark),
                _buildPackGridItem("50", isDark),
                const SizedBox(height: 16),
                _buildPackGridItem("100", isDark),
                const SizedBox(height: 16),
                _buildPackGridItem("150", isDark),
                const SizedBox(height: 16),
                _buildPackGridItem("250", isDark),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.amber, Colors.yellow, Colors.white],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackGridItem(String type, bool isDark) {
    int remaining = pools[type]?.length ?? 0;
    int total = initialRarityCounts[type]?.values.reduce((a, b) => a + b) ?? 0;

    // Calculate rarities count
    int epics = pools[type]?.where((p) => p.stars == 5).length ?? 0;
    int highlights = pools[type]?.where((p) => p.stars == 4).length ?? 0;
    int featured = pools[type]?.where((p) => p.stars == 3).length ?? 0;
    int standard = pools[type]?.where((p) => p.stars <= 2).length ?? 0;

    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$type talik Pack",
                      style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black)),
                  Text("Holati: $remaining / $total",
                      style: GoogleFonts.outfit(
                          color: isDark ? Colors.white70 : Colors.black,
                          fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _viewHistory(type, isDark),
                    icon: Icon(Icons.history,
                        color: isDark ? Colors.white : Colors.black, size: 28),
                    tooltip: "Tarixni ko'rish",
                  ),
                  IconButton(
                    onPressed: () => _viewPackPlayers(type, isDark),
                    icon: Icon(Icons.group,
                        color: isDark ? Colors.white : Colors.black, size: 28),
                    tooltip: "O'yinchilarni ko'rish",
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Rarity counts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCountTag("Epic/ShowTime", epics,
                  initialRarityCounts[type]?[5] ?? 0, Colors.amber),
              _buildCountTag("Highlight", highlights,
                  initialRarityCounts[type]?[4] ?? 0, Colors.blueAccent),
              _buildCountTag("Features", featured,
                  initialRarityCounts[type]?[3] ?? 0, Colors.blueGrey),
              _buildCountTag("Standart", standard,
                  initialRarityCounts[type]?[2] ?? 0, const Color(0xFF919191)),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: remaining / total,
              backgroundColor: Colors.white12,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      remaining >= 1 ? () => _confirmPull(type, 1) : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                          side:
                              BorderSide(color: Colors.grey.withOpacity(0.3)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, color: Colors.grey, size: 16),
                      const SizedBox(width: 6),
                      Text("x1",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 13)),
                      const SizedBox(width: 6),
                      Container(
                        height: 15,
                        width: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Image.asset('assets/images/elements/coins.png',
                          width: 16, height: 16),
                      const SizedBox(width: 6),
                      Text("100",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      remaining >= 10 ? () => _confirmPull(type, 10) : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                          side:
                              BorderSide(color: Colors.grey.withOpacity(0.3)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, color: Colors.grey, size: 16),
                      const SizedBox(width: 6),
                      Text("x10",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 13)),
                      const SizedBox(width: 6),
                      Container(
                        height: 15,
                        width: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Image.asset('assets/images/elements/coins.png',
                          width: 16, height: 16),
                      const SizedBox(width: 6),
                      Text("900",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountTag(String label, int count, int total, Color color) {
    return Column(
      children: [
        Text("$count/$total",
            style: GoogleFonts.outfit(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: GoogleFonts.outfit(
                color: color.withOpacity(0.7), fontSize: 10)),
      ],
    );
  }

  Widget _buildCoinDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber, width: 1.5)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/elements/coins.png',
              width: 20, height: 20),
          const SizedBox(width: 6),
          Text(coins.toString(),
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildRNGInfoCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDark ? Colors.blue.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ],
          border: Border.all(
              color: isDark
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05))),
      child: Text(
        "eFootballda RNG — bu pack ichida oldindan belgilangan futbolchilar to‘plamidan har ochishda tasodifiy tarzda tanlash tizimi. Har bir ochishda tanlangan futbolchi pool’dan olib tashlanadi, shu sabab natijalar omadga bog‘liq bo‘lsa-da, butun jarayon matematik tartib asosida ishlaydi",
        style: GoogleFonts.outfit(
            fontSize: 12, color: isDark ? Colors.blueGrey : Colors.black54),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPlayerCard(PackPlayer player, {bool mini = false}) {
    Color rarityColor = Colors.white;
    if (player.stars == 5)
      rarityColor = Colors.amber;
    else if (player.stars == 4)
      rarityColor = Colors.blueAccent;
    else if (player.stars == 3) rarityColor = Colors.blueGrey;

    return Container(
      padding: EdgeInsets.all(mini ? 6 : 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rarityColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: rarityColor.withOpacity(0.05), blurRadius: 4)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  player.stars,
                  (i) => Icon(Icons.star,
                      color: rarityColor, size: mini ? 8 : 14))),
          const SizedBox(height: 4),
          Icon(Icons.person, color: rarityColor, size: mini ? 28 : 45),
          const SizedBox(height: 4),
          Text(player.name,
              style: GoogleFonts.outfit(
                  fontSize: mini ? 10 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.fade),
          if (!mini)
            Text(player.position,
                style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 2),
          Text(player.rarity,
              style: GoogleFonts.outfit(
                  fontSize: mini ? 7 : 10,
                  color: rarityColor,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRaritySummaryForList(List<PackPlayer> players, bool isDark) {
    int epics = players.where((p) => p.stars == 5).length;
    int highlights = players.where((p) => p.stars == 4).length;
    int featured = players.where((p) => p.stars == 3).length;
    int standard = players.where((p) => p.stars <= 2).length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        if (epics > 0) _buildRarityChipDetailed("Epic", epics, Colors.amber),
        if (highlights > 0)
          _buildRarityChipDetailed("Highlight", highlights, Colors.blueAccent),
        if (featured > 0)
          _buildRarityChipDetailed("Featured", featured, Colors.blueGrey),
        if (standard > 0)
          _buildRarityChipDetailed(
              "Standard", standard, const Color(0xFF919191)),
      ],
    );
  }

  Widget _buildRarityChipDetailed(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$count ",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
