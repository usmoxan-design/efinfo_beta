// -----------------------------------------------------------------------------
// 5. DETAIL SCREEN (SLIVER APP BAR + TABS)
// -----------------------------------------------------------------------------

import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/formationsmodel.dart';

class FormationDetailScreen extends StatelessWidget {
  final Formation formation;

  const FormationDetailScreen({super.key, required this.formation});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 420, // Maydon balandligi
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor:
                    themeProvider.getTheme().scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: innerBoxIsScrolled
                      ? Text(formation.name,
                          style: GoogleFonts.outfit(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold))
                      : null,
                  background: Padding(
                    padding: const EdgeInsets.only(
                        top: 100, bottom: 80, left: 30, right: 30),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: GlassContainer(
                          borderRadius: 24,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: CustomPaint(
                              painter: RealisticFieldPainter(
                                positions: formation.positions,
                                playerRadius: 10.0,
                                isDark: isDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  indicatorColor: const Color(0xFF06DF5D),
                  indicatorWeight: 3,
                  labelColor: isDark ? Colors.white : Colors.black,
                  unselectedLabelColor:
                      isDark ? Colors.white38 : Colors.black38,
                  labelStyle: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(text: "UMUMIY"),
                    Tab(text: "STRATEGIYA"),
                    Tab(text: "TARKIB"),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildInfoTab(
                context: context,
                icon: Icons.info_outline,
                title: "Format haqida",
                content: formation.description,
                tagTitle: "Qiyinlik darajasi",
                tagContent: formation.difficulty.name.toUpperCase(),
                isDark: isDark,
              ),
              _buildInfoTab(
                context: context,
                icon: Icons.sports_soccer,
                title: "O'yin Uslubi",
                content: formation.bestFor,
                extraNote: formation.warning,
                isDark: isDark,
              ),
              _buildInfoTab(
                context: context,
                icon: Icons.people_outline,
                title: "Tavsiya",
                content: formation.playerRecommendations,
                isList: true,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTab({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    String? tagTitle,
    String? tagContent,
    String? extraNote,
    bool isList = false,
    required bool isDark,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF06DF5D), size: 28),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (tagTitle != null) ...[
            Row(
              children: [
                Text("$tagTitle: ",
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white54 : Colors.black54)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFF06DF5D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF06DF5D).withOpacity(0.3))),
                  child: Text(tagContent!,
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF06DF5D),
                          fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 20),
          ],
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Text(
              content,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ),
          if (extraNote != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 20),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(extraNote,
                        style: GoogleFonts.outfit(
                            color: Colors.orange, fontSize: 13))),
              ],
            )
          ]
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. PROFESSIONAL PAINTER (REALISTIK MAYDON)
// -----------------------------------------------------------------------------

class RealisticFieldPainter extends CustomPainter {
  final List<List<double>> positions;
  final double playerRadius;
  final bool showPlayers;
  final bool isDark;

  RealisticFieldPainter({
    required this.positions,
    this.playerRadius = 6.0,
    this.showPlayers = true,
    this.isDark = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Chim (Grass Stripes)
    final paintGrass1 = Paint()
      ..color = isDark
          ? const Color(0xFF1B5E20)
          : const Color(0xFF2E7D32); // To'q yashil
    final paintGrass2 = Paint()
      ..color = isDark
          ? const Color(0xFF2E7D32)
          : const Color(0xFF388E3C); // Och yashil

    // Maydon foni
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintGrass1);

    // Polosalar chizish
    int stripes = 10;
    double stripeHeight = size.height / stripes;
    for (int i = 0; i < stripes; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
          paintGrass2,
        );
      }
    }

    // 2. Chiziqlar (Lines)
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Tashqi ramka
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), linePaint);

    // Markaziy chiziq
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), linePaint);

    // Markaziy doira
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width * 0.15, linePaint);
    // Markaziy nuqta
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 2,
        Paint()..color = Colors.white);

    // Jarima maydonchasi (Tepa - Raqib)
    _drawPenaltyArea(canvas, size, linePaint, true);
    // Jarima maydonchasi (Past - Biz)
    _drawPenaltyArea(canvas, size, linePaint, false);

    // Burchaklar (Corners)
    _drawCorners(canvas, size, linePaint);

    // 3. O'yinchilar
    if (showPlayers) {
      final playerPaint = Paint()..color = Colors.white;
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final borderPaint = Paint()
        ..color = const Color(0xFF121212)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (var pos in positions) {
        double x = pos[0] * size.width;
        double y = pos[1] * size.height;
        Offset center = Offset(x, y);

        // O'yinchi soyasi
        canvas.drawCircle(center.translate(2, 2), playerRadius, shadowPaint);
        // O'yinchi
        canvas.drawCircle(center, playerRadius, playerPaint);
        // O'yinchi chegarasi (kontur)
        canvas.drawCircle(center, playerRadius, borderPaint);
      }
    }
  }

  void _drawPenaltyArea(Canvas canvas, Size size, Paint paint, bool isTop) {
    double boxWidth = size.width * 0.5;
    double boxHeight = size.height * 0.16;
    double smallBoxWidth = size.width * 0.25;
    double smallBoxHeight = size.height * 0.06;

    double yStart = isTop ? 0 : size.height - boxHeight;
    double smallYStart = isTop ? 0 : size.height - smallBoxHeight;

    // Katta jarima
    canvas.drawRect(
      Rect.fromLTWH((size.width - boxWidth) / 2, yStart, boxWidth, boxHeight),
      paint,
    );
    // Kichik darvoza oldi
    canvas.drawRect(
      Rect.fromLTWH((size.width - smallBoxWidth) / 2, smallYStart,
          smallBoxWidth, smallBoxHeight),
      paint,
    );

    // Jarima yoyi (Arc)
    double arcY = isTop ? boxHeight : size.height - boxHeight;
    Rect arcRect = Rect.fromCircle(
        center: Offset(size.width / 2, arcY), radius: size.width * 0.1);
    double startAngle = isTop ? 0.6 : 3.7;
    canvas.drawArc(arcRect, startAngle, 2, false, paint);
  }

  void _drawCorners(Canvas canvas, Size size, Paint paint) {
    double r = 10;
    canvas.drawArc(Rect.fromLTWH(-r, -r, 2 * r, 2 * r), 0, 1.57, false, paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r, -r, 2 * r, 2 * r), 1.57, 1.57,
        false, paint);
    canvas.drawArc(Rect.fromLTWH(-r, size.height - r, 2 * r, 2 * r), -1.57,
        1.57, false, paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r, size.height - r, 2 * r, 2 * r),
        3.14, 1.57, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
