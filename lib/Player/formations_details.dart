// -----------------------------------------------------------------------------
// 5. DETAIL SCREEN (SLIVER APP BAR + TABS)
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../models/formationsmodel.dart';

class FormationDetailScreen extends StatelessWidget {
  final Formation formation;

  const FormationDetailScreen({super.key, required this.formation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 400, // Maydon balandligi
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF0D0D0D),
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.only(
                        top: 80, bottom: 60, left: 20, right: 20),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E7D32).withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: -10,
                              )
                            ],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CustomPaint(
                              painter: RealisticFieldPainter(
                                positions: formation.positions,
                                playerRadius: 10.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: const TabBar(
                  indicatorColor: Color(0xFF00C853),
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white38,
                  labelStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
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
                icon: Icons.info_outline,
                title: "Format haqida",
                content: formation.description,
                tagTitle: "Qiyinlik darajasi",
                tagContent: formation.difficulty.name.toUpperCase(),
              ),
              _buildInfoTab(
                icon: Icons.sports_soccer,
                title: "O'yin Uslubi",
                content: formation.bestFor,
                extraNote: formation.warning,
              ),
              _buildInfoTab(
                icon: Icons.people_outline,
                title: "Tavsiya",
                content: formation.playerRecommendations,
                isList: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTab({
    required IconData icon,
    required String title,
    required String content,
    String? tagTitle,
    String? tagContent,
    String? extraNote,
    bool isList = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00C853), size: 28),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
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
                    style: const TextStyle(color: Colors.white54)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(tagContent!,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 20),
          ],
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              content,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
                height: 1.6,
                fontFamily:
                    isList ? "Monospace" : null, // Ro'yxat uchun mos shrift
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
                        style: const TextStyle(
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

  RealisticFieldPainter({
    required this.positions,
    this.playerRadius = 6.0,
    this.showPlayers = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Chim (Grass Stripes)
    final paintGrass1 = Paint()..color = const Color(0xFF2E7D32); // To'q yashil
    final paintGrass2 = Paint()..color = const Color(0xFF388E3C); // Och yashil

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
