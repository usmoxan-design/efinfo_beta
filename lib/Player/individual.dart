import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- 1. MODEL VA MA'LUMOTLAR QISMI (DATA LAYER) ---

enum InstructionType { attack, defense }

class InstructionModel {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final InstructionType type;
  final String imageAsset;

  const InstructionModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    required this.imageAsset,
  });
}

class AppData {
  static const String anchoringText = """
ANCHORING (LANGAR USHLAB TURISH)

Bu ko‘rsatma o‘yinchini o‘z pozitsiyasida «qotib qo‘yadi» va **gorizontal siljishdan (drifting out of position horizontally) cheklaydi**.
Masalan, markaziy hujumchingiz markaziy pozitsiyani saqlaydi, qanot yarim himoyachilari ichkariga kirib ketmaydi.
U deyarli oldinga chiqmaydi, faqat o‘z zonasini qo‘riqlaydi.

Qayerda ishlatiladi?
• DMF (masalan, Rodri, Casemiro)
• Ikkinchi DMF yoki CB (himoya mustahkam bo‘lishi kerak bo‘lsa)
• Possession o‘yin uslubi
• Raqib Quick Counter bilan o‘ynasa

Afzalliklari:
– Himoyada bo‘shliq qoldirmaydi
– Markazni butunlay yopadi
– Raqib qarshi hujumda to‘p olish qiyinlashadi
""";

  static const String offensiveText = """
OFFENSIVE (HUJUMGA FAOL)

Tayinlangan o‘yinchi odatdagidan **yuqoriroq pozitsiyada (higher up the field) joylashadi**.
Bu ko‘rsatma Hujumchi (FW) o‘yinchilarga berilishi mumkin emas.
O‘yinchi hujum vaqtida oldinga juda ko‘p chiqadi, qanotlardan yoki markazdan hujum qiladi.

Qayerda ishlatiladi?
• LB / RB (Trent, Cancelo)
• CMF (De Bruyne, Bellingham)
• AMF (Odegaard, Bruno Fernandes)
• Out Wide va Long Ball Counter uslubi

Afzalliklari:
– Hujumda ko‘proq odam bo‘ladi
– Qanotlardan ko‘proq markazlash
– Gol va assist soni oshadi

Kamchiliklari:
– Orqada bo‘shliq qoldiradi
– Raqib tez hujum qilsa, oson gol yeyish mumkin
""";

  static const String defensiveText = """
DEFENSIVE (ORQADA QOLISH)

Tayinlangan o‘yinchi hujumda oldinga chiqishdan **o‘zini tiyadi (refrain from pushing forward in offense)**.
O‘yinchi hujumga deyarli qo‘shilmaydi, doim himoyada qoladi.

Eng yaxshi joyi:
• Fullback (LB/RB) – raqib qanotdan hujum qilmasin (bu eng muhimi)
• DMF – markazni yopish
• CB – pozitsiyani saqlash

Qachon majburiy?
• Raqibda Vinicius, Mbappe, Salah bo‘lsa
• Siz 0:1 yoki 1:2 hisobda oldindasiz va vaqt o‘tkazmoqchisiz
""";

  static const String manMarkingText = """
MAN MARKING (SHAXSIY QO‘RIQLASH)

Ko‘rsatma berilgan o‘yinchi tanlangan nishonni **odatdagidan qattiqroq qo‘riqlaydi (perform a tighter man marking on his target)**.
Belgilangan o‘yinchilar nishonni kuzatib borayotganligi sababli himoyada **bo'shliqlar paydo bo'lishi mumkin (space tends to open up)**.
Bu ko‘rsatma faqat o‘yin ichida (in-match) berilishi mumkin.

Afzalliklari:
– Raqib yulduz o‘yinchi deyarli to‘p olmasligi mumkin
– Gol xavfi 70-80% kamayadi

Kamchiliklari:
– O‘yinchi charchaydi
– Pozitsiyani yo‘qotishi mumkin → bo‘shliq paydo bo‘ladi
""";

  static const String tightMarkingText = """
TIGHT MARKING (QATTIQ BOSIM)

Tanlangan raqib o'yinchisi odatdagidan ancha **qattiqroq qo'riqlanadi (marked much tighter than usual)**, qo'riqchi o'yinchining pozitsiyasiga qarab almashinishi mumkin.
Belgilangan o‘yinchilar raqibni kuzatib borayotganligi sababli himoyada **bo'shliqlar paydo bo'lishi mumkin (Space tends to open up)**.
Bu ko‘rsatma faqat o‘yin ichida (in-match) berilishi mumkin.

Eng yaxshi joyi:
• 2 ta CMF → Tight Marking = Markaz butunlay yopiladi!
• DMF + CMF kombinatsiyasi

Natija:
Raqib o‘rtada pas bera olmaydi, xato qiladi, to‘p yo‘qotadi → siz qarshi hujum boshlaysiz!
""";

  static const String deepLineText = """
DEEP DEFENSIVE LINE (PAST HIMOYA CHIZIG‘I)

Ko‘rsatma berilgan o‘yinchi o‘zini **himoyaga osongina qo'shilishga imkon beradigan pozitsiyaga orqaga tortadi (drop back to a position that allows him to join the defense with ease)**.
Bu ko‘rsatma Himoyachi (DF) o‘yinchisiga tayinlanishi mumkin emas.
Agar 5 himoyachi bilan o'ynalsa, Yarim himoyachi (MF) o'yinchisiga ham tayinlanishi mumkin emas.

Afzalligi:
Tez hujumchilar offsaydga tushadi yoki to‘p yetmaydi.

Kamchiligi:
Agar raqib possession bilan o‘ynasa – sizning darvozadagacha katta bo‘sh joy bo‘ladi.
""";

  static const String counterTargetText = """
COUNTER TARGET (QARSHI HUJUM NISHONI)

Ko‘rsatma berilgan o‘yinchi **himoyaga yordam berish uchun orqaga qaytish o‘rniga raqib jarima maydonchasi yaqinida qoladi (stay in the vicinity of the opposition's box rather than dropping back to help the defense)**.
Bu shuni anglatadiki, bu hujumchilar oldinga va orqaga yugurish uchun **quvvat sarflamaydilar (do not use up energy running back and forth)**.
Qarshi hujum boshlanganda to‘p birinchi navbatda shu o‘yinga uzatiladi.

Eng yaxshi o‘yinchi turlari:
• CF (Haaland, Lewandowski)
• SS (Messi, Neymar)
• Tez AMF (Foden, Musiala)

Natija:
Quick Counter va Long Ball Counter uslubida gol soni 2-3 baravar oshadi!
""";

  static List<InstructionModel> get instructions => [
        const InstructionModel(
            title: "Anchoring",
            description: anchoringText,
            icon: Icons.anchor,
            color: AppColors.accentOrange,
            type: InstructionType.attack,
            imageAsset: 'anchoring.jpg'),
        const InstructionModel(
            title: "Offensive",
            description: offensiveText,
            icon: Icons.arrow_circle_up,
            color: AppColors.accentGreen,
            type: InstructionType.attack,
            imageAsset: 'offensive.jpg'),
        const InstructionModel(
            title: "Defensive",
            description: defensiveText,
            icon: Icons.shield,
            color: AppColors.accentPink,
            type: InstructionType.attack,
            imageAsset: 'defensive.jpg'),
        const InstructionModel(
            title: "Man Marking",
            description: manMarkingText,
            icon: Icons.person_pin_circle,
            color: AppColors.accentBlue,
            type: InstructionType.defense,
            imageAsset: 'man_marking.jpg'),
        const InstructionModel(
            title: "Tight Marking",
            description: tightMarkingText,
            icon: Icons.compress,
            color: AppColors.accentOrange,
            type: InstructionType.defense,
            imageAsset: 'tight_marking.jpg'),
        const InstructionModel(
            title: "Deep Line",
            description: deepLineText,
            icon: Icons.vertical_align_bottom,
            color: AppColors.accentBlue,
            type: InstructionType.defense,
            imageAsset: 'deep_line.jpg'),
        const InstructionModel(
            title: "Counter Target",
            description: counterTargetText,
            icon: Icons.track_changes,
            color: AppColors.accentGreen,
            type: InstructionType.defense,
            imageAsset: 'counter_target.jpg'),
      ];
}

class ModernInstructionsListPage extends StatelessWidget {
  const ModernInstructionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final attackList = AppData.instructions
        .where((e) => e.type == InstructionType.attack)
        .toList();
    final defenseList = AppData.instructions
        .where((e) => e.type == InstructionType.defense)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Individual Instructions",
          style: GoogleFonts.outfit(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child:
                  Image.asset('assets/images/indivins.jpg', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader("Offense", AppColors.accentPink),
          ...attackList.map((e) => _InstructionCard(item: e)),
          const SizedBox(height: 24),
          _buildSectionHeader("Defense", AppColors.accentBlue),
          ...defenseList.map((e) => _InstructionCard(item: e)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tactics Info,",
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: AppColors.textDim,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Game Strategy",
          style: GoogleFonts.outfit(
            fontSize: 28,
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
              height: 24,
              width: 4,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: AppColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  final InstructionModel item;

  const _InstructionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, __, ___) =>
                  ModernInstructionDetailPage(item: item),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(item.icon, color: item.color, size: 24),
        ),
        title: Text(
          item.title,
          style: GoogleFonts.outfit(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item.description.split('\n')[2],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              color: AppColors.textDim,
              fontSize: 13,
            ),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            color: AppColors.textDim.withOpacity(0.3), size: 16),
      ),
    );
  }
}

// --- 4. TAFSILOTLAR SAHIFASI (UPDATED DETAIL PAGE) ---

class ModernInstructionDetailPage extends StatelessWidget {
  final InstructionModel item;

  const ModernInstructionDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Instruction Detail",
          style: GoogleFonts.outfit(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildHeroSection(),
          const SizedBox(height: 32),
          _buildContentCard(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Center(
      child: Column(
        children: [
          Hero(
            tag: item.title,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                shape: BoxShape.circle,
                border:
                    Border.all(color: item.color.withOpacity(0.2), width: 1),
              ),
              child: Icon(item.icon, size: 48, color: item.color),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: GoogleFonts.outfit(
              color: AppColors.textWhite,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              item.type == InstructionType.attack
                  ? "Offensive Strategy"
                  : "Defensive Strategy",
              style: GoogleFonts.outfit(
                color: item.color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Tactical Diagram"),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                'assets/images/instruction/${item.imageAsset}',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surface,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported_rounded,
                              color: AppColors.textDim.withOpacity(0.3),
                              size: 32),
                          const SizedBox(height: 8),
                          Text(
                            "Diagram not available",
                            style: GoogleFonts.outfit(
                                color: AppColors.textDim, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionTitle("Description"),
          const SizedBox(height: 12),
          Text(
            item.description.trim(),
            style: GoogleFonts.outfit(
              color: AppColors.textDim,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: item.color.withOpacity(0.1),
                foregroundColor: item.color,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: item.color.withOpacity(0.2)),
                ),
              ),
              child: Text(
                "Got it",
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: AppColors.textWhite,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
