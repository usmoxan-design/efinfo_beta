import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';

class PlayerModelPage extends StatelessWidget {
  const PlayerModelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Player Model Tushuntirish",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.black, Colors.grey[900]!]
                : [Colors.grey[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntroCard(isDark),
              const SizedBox(height: 32),
              _buildSectionTitle(
                  "Gauge parametrlar (eFHUB ko'rsatkichlari)", isDark),
              const SizedBox(height: 16),
              _buildGaugeSection(isDark),
              const SizedBox(height: 32),
              _buildSectionTitle("Raqamli parametrlar (1-15 shkala)", isDark),
              const SizedBox(height: 16),
              _buildNumericSection(isDark),
              const SizedBox(height: 32),
              _buildBottomNote(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.accessibility_new_rounded,
                  color: AppColors.accentBlue, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Player Model nima?",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "eFootball o'yinida o'yinchilarning jismoniy modeli (physique) muhim rol o'ynaydi. Bu parametrlar rasmiy o'yinda ko'rinmaydi, lekin eFHUB saytida ko'rsatiladi. Ular duelda, interceptionda, sakrashda va boshqa jismoniy harakatlarda ta'sir qiladi.",
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/pl_player_model.jpg',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.accentBlue,
        ),
      ),
    );
  }

  Widget _buildGaugeSection(bool isDark) {
    return Column(
      children: [
        _buildGaugeItem(
          "Leg Coverage (Oyoq qoplami)",
          187.2,
          250,
          "O'yinchining oyoqlari bilan qoplashi mumkin bo'lgan masofa. Yuqori qiymat interception (to'pni kesib olish) va duelda ustunlik beradi, ayniqsa himoyachilar uchun.",
          isDark,
        ),
        const SizedBox(height: 16),
        _buildGaugeItem(
          "Arm Coverage (Qo'l qoplami)",
          175.5,
          250,
          "Qo'llar bilan qoplash masofasi. Darvozabonlar (GK) uchun zarbalarni qaytarishda, maydon o'yinchilari uchun esa duellarda muvozanat saqlashda muhim.",
          isDark,
        ),
        const SizedBox(height: 16),
        _buildGaugeItem(
          "Torso Collision (Gavdasi (ko‘krak–bel qismi)",
          54.8,
          100,
          "Raqib bilan to‘qnashuvdagi ta’sir zonasi va kuchi Jismoniy duelda (yelkama-yelka) va to'pni tanasi bilan himoya qilishda katta ta'sir ko'rsatadi.",
          isDark,
        ),
        const SizedBox(height: 16),
        _buildGaugeItem(
          "Jump Height (Sakrash balandligi)",
          276.4,
          350,
          "O'yinchining sakrashda yetishi mumkin bo'lgan maksimal nuqtasi. Havodagi duellar va bosh bilan o'ynashda (heading) hal qiluvchi parametr.",
          isDark,
        ),
        const SizedBox(height: 16),
        _buildGaugeItem(
          "Height Based on Leg (Oyoq uzunligi bo'yicha)",
          194.2,
          220,
          "Oyoq uzunligiga qarab effektli balandlik. Oyoqlari uzun o'yinchilarning interception radiusi keng bo'ladi va ular to'pni olib qo'yishda ustunlikka ega.",
          isDark,
        ),
      ],
    );
  }

  Widget _buildGaugeItem(
      String title, double value, double max, String desc, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        children: [
          Row(
            children: [
              _EFHubRadialGauge(
                value: value,
                max: max,
                size: 90,
                isDark: isDark,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      desc,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumericSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle("Yuqori tana", isDark),
        const SizedBox(height: 12),
        _buildNumericGroup([
          {
            "name": "Arm Length (Qo'l uzunligi)",
            "val": "8/15",
            "desc":
                "To'pni ushlab qolish, muvozanat va pressingda qo'llarning uzunligi."
          },
          {
            "name": "Shoulder Width (Yelka kengligi)",
            "val": "9/15",
            "desc": "Kuchli jismoniy kontakt va duellarda ustunlik beradi."
          },
          {
            "name": "Neck Length (Bo'yin uzunligi)",
            "val": "8/15",
            "desc": "Havo to'plari (heading) va sakrash paytidagi barqarorlik."
          },
          {
            "name": "Chest Measurement (Ko'krak kengligi)",
            "val": "5/15",
            "desc":
                "Tana bilan raqibni to'sib qolish va himoyalanish qobiliyati."
          },
          {
            "name": "Neck Size (Bo'yin qalinligi)",
            "val": "7/15",
            "desc": "Jismoniy bosim va qarshilikka bo'lgan chidamlilik."
          },
          {
            "name": "Shoulder Height (Yelka balandligi)",
            "val": "7/15",
            "desc":
                "O'yinchining tana muvozanati va ko'rinishiga ta'sir qiladi."
          },
        ], isDark),
        const SizedBox(height: 24),
        _buildSubSectionTitle("Pastki tana", isDark),
        const SizedBox(height: 12),
        _buildNumericGroup([
          {
            "name": "Leg Length (Oyoq uzunligi)",
            "val": "8/15",
            "desc": "Tezlik, qadam tashlash oralig'i va intersepsiya radiusi."
          },
          {
            "name": "Thigh Size (Son mushaklari)",
            "val": "6/15",
            "desc": "Tezlanish (acceleration) va zarba berishdagi kuch asosi."
          },
          {
            "name": "Waist Size (Bel o'lchami)",
            "val": "5/15",
            "desc": "Chaqqonlik, tezkor burilish va tana egiluvchanligi."
          },
          {
            "name": "Arm Size (Qo'l mushaklari)",
            "val": "6/15",
            "desc": "Fizik kurashlarda raqibga qarshilik ko'rsatish kuchi."
          },
          {
            "name": "Calf Size (Boldir mushaklari)",
            "val": "6/15",
            "desc": "Explosive power, sakrash va o'rindan tez siljish (start)."
          },
        ], isDark),
      ],
    );
  }

  Widget _buildSubSectionTitle(String title, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildNumericGroup(List<Map<String, dynamic>> params, bool isDark) {
    return Column(
      children: params
          .map((p) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              p['name'],
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              p['val'],
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.accentGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p['desc'],
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildBottomNote(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_rounded,
              color: Colors.amber, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Bu parametrlar o'yin ichida yashirin bo'lib, faqat eFHUB orqali ko'rish mumkin. Yuqori qiymatlar odatda yaxshi, lekin pozitsiyaga qarab farq qiladi (masalan, GK uchun Arm/Leg Coverage juda muhim).",
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EFHubRadialGauge extends StatelessWidget {
  final double value;
  final double max;
  final double size;
  final bool isDark;

  const _EFHubRadialGauge({
    required this.value,
    required this.max,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / max).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RadialPainter(
              progress: progress,
              isDark: isDark,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: GoogleFonts.outfit(
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                "cm",
                style: GoogleFonts.outfit(
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RadialPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _RadialPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.1;

    // Background track
    final bgPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Progress arc
    final rect =
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    final gradPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.accentGreen,
          AppColors.accentBlue,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, gradPaint);

    // Shiny overlay dots (visual flair like EF Hub)
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.2);
    final dotAngle = startAngle + sweepAngle;
    final dotPos = Offset(
      center.dx + (radius - strokeWidth / 2) * math.cos(dotAngle),
      center.dy + (radius - strokeWidth / 2) * math.sin(dotAngle),
    );
    canvas.drawCircle(dotPos, strokeWidth * 0.4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
