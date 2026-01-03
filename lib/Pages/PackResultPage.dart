import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:efinfo_beta/models/pack_player.dart';
import 'package:confetti/confetti.dart';

class PackResultPage extends StatefulWidget {
  final List<PackPlayer> players;
  final VoidCallback onDone;

  const PackResultPage({
    super.key,
    required this.players,
    required this.onDone,
  });

  @override
  State<PackResultPage> createState() => _PackResultPageState();
}

class _PackResultPageState extends State<PackResultPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));

    // Check for epics
    int epicsCount = widget.players.where((p) => p.stars == 5).length;

    // Trigger confetti if there is at least one 5-star or 4-star player
    if (widget.players.any((p) => p.stars >= 4)) {
      _confettiController.play();
    }

    // Show animations after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (epicsCount >= 2) {
        _showBlackAnimation();
      } else if (epicsCount == 1) {
        _showEpicAnimation(widget.players.firstWhere((p) => p.stars == 5).name);
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000814) : const Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Olingan o'yinchilar",
            style: GoogleFonts.outfit(
                color: textColor, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            widget.onDone();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildRaritySummary(isDark),
              Expanded(
                child: GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: widget.players.length,
                  itemBuilder: (context, index) =>
                      _buildPlayerCard(widget.players[index], isDark),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onDone();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("DAVOM ETISH",
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.amber,
                Colors.yellow,
                Colors.white,
                Colors.blueAccent
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(PackPlayer player, bool isDark) {
    Color rarityColor = isDark ? Colors.white : Colors.grey;
    if (player.stars == 5)
      rarityColor = Colors.amber;
    else if (player.stars == 4)
      rarityColor = Colors.blueAccent;
    else if (player.stars == 3) rarityColor = Colors.blueGrey;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rarityColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(player.stars,
                (i) => Icon(Icons.star, color: rarityColor, size: 14)),
          ),
          const SizedBox(height: 8),
          Icon(Icons.person, color: rarityColor, size: 50),
          const SizedBox(height: 8),
          Text(player.name,
              style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87),
              textAlign: TextAlign.center,
              maxLines: 1),
          Text(player.position,
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54)),
          Text(player.rarity,
              style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: rarityColor,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showEpicAnimation(String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 100),
              Text("EPIK O'YINCHI TUSHDI!",
                  style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text(name,
                  style: GoogleFonts.outfit(fontSize: 24, color: Colors.amber)),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black),
                  child: const Text("DAXSHAT!")),
            ],
          ),
        ),
      ),
    );
  }

  void _showBlackAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black.withOpacity(0.95),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flash_on, color: Colors.purpleAccent, size: 120),
              const SizedBox(height: 20),
              Text("🔥 DAXSHATLI OMAD! 🔥",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2)),
              const SizedBox(height: 10),
              Text("BLACK ANIMATION",
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Bitta ochishda 2 ta va undan ko'p epik!",
                  style: GoogleFonts.outfit(color: Colors.white70)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text("DAVOM ETISH"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRaritySummary(bool isDark) {
    int epics = widget.players.where((p) => p.stars == 5).length;
    int highlights = widget.players.where((p) => p.stars == 4).length;
    int featured = widget.players.where((p) => p.stars == 3).length;
    int standard = widget.players.where((p) => p.stars <= 2).length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Packdan tushgan o'yinchilar",
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (epics > 0)
                _buildRarityChip("Epic/Showtime", epics, Colors.amber),
              if (highlights > 0)
                _buildRarityChip("Highlight", highlights, Colors.blueAccent),
              if (featured > 0)
                _buildRarityChip("Featured", featured, Colors.blueGrey),
              if (standard > 0)
                _buildRarityChip("Standard/Ordinary", standard, Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRarityChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$count ta ",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
