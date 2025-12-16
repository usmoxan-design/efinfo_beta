import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

// --- 1. MODEL VA MA'LUMOTLAR QISMI (DATA LAYER) ---

enum InstructionType { attack, defense }

class InstructionModel {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final InstructionType type;
  // YANGI: Rasm uchun asset nomi
  final String imageAsset;

  const InstructionModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    required this.imageAsset, // YANGI
  });
}

class AppData {
  // RASMLAR FAQAT KO'RSATMA MAQSADIDA QO'SHILDI.
  // Ularni loyihangizning 'assets/images' katalogiga qo'yishingiz shart.

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
            color: Colors.orange,
            type: InstructionType.attack,
            imageAsset: 'anchoring.jpg'), // Yuborgan rasm nomi
        const InstructionModel(
            title: "Offensive",
            description: offensiveText,
            icon: Icons.arrow_circle_up,
            color: Colors.green,
            type: InstructionType.attack,
            imageAsset: 'offensive.jpg'), // Yuborgan rasm nomi
        const InstructionModel(
            title: "Defensive",
            description: defensiveText,
            icon: Icons.shield,
            color: Colors.redAccent,
            type: InstructionType.attack,
            imageAsset: 'defensive.jpg'), // Yuborgan rasm nomi
        const InstructionModel(
            title: "Man Marking",
            description: manMarkingText,
            icon: Icons.person_pin_circle,
            color: Colors.purple,
            type: InstructionType.defense,
            imageAsset: 'man_marking.jpg'), // Yuborgan rasm nomi
        const InstructionModel(
            title: "Tight Marking",
            description: tightMarkingText,
            icon: Icons.compress,
            color: Colors.deepOrange,
            type: InstructionType.defense,
            imageAsset: 'tight_marking.jpg'), // Yuborgan rasm nomi
        const InstructionModel(
            title: "Deep Line",
            description: deepLineText,
            icon: Icons.vertical_align_bottom,
            color: Colors.indigo,
            type: InstructionType.defense,
            imageAsset: 'deep_line.jpg'), // Yuborgan rasm nomi
        const InstructionModel(
            title: "Counter Target",
            description: counterTargetText,
            icon: Icons.track_changes,
            color: Colors.amber,
            type: InstructionType.defense,
            imageAsset: 'counter_target.jpg'), // Yuborgan rasm nomi
      ];
}

// --- 2. ASOSIY SAHIFA (UI LAYER) ---
// (Bu qism o'zgartirilmadi, faqat to'liqligi uchun takrorlanmoqda)

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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/indivins.jpg',
                    ),
                  ),
                ),
                _buildSectionHeader(
                    "Offense (Hujum ko'rsatmalari)", AppColors.accent),
                ...attackList.map((e) => _InstructionCard(item: e)),
                const SizedBox(height: 24),
                _buildSectionHeader(
                    "Defense (Himoya ko'rsatmalari)", Colors.blueAccent),
                ...defenseList.map((e) => _InstructionCard(item: e)),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        // centerTitle: true,
        title: const Text(
          "Individual Instructions",
          style: TextStyle(
            color: Colors.white,
            // fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.accent.withOpacity(0.1),
                AppColors.background,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.sports_soccer,
              size: 60,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(height: 20, width: 4, color: color),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. ELEMENT KARTOCHKASI (WIDGET) ---
// (Bu qism o'zgartirilmadi, faqat to'liqligi uchun takrorlanmoqda)

class _InstructionCard extends StatelessWidget {
  final InstructionModel item;

  const _InstructionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.accent.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Hero(
                  tag: item.title,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: item.color.withOpacity(0.3), width: 1.5),
                    ),
                    child: Icon(item.icon, color: item.color, size: 26),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // Faqat birinchi haqiqiy ma'lumot qatorini olish
                        item.description.split('\n')[2].length > 40
                            ? "${item.description.split('\n')[2].substring(0, 40)}..."
                            : item.description.split('\n')[2],
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.3), size: 16),
              ],
            ),
          ),
        ),
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
      body: Stack(
        children: [
          // Orqa fon effekti
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.color.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                      color: item.color, blurRadius: 100, spreadRadius: 10),
                ],
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                expandedHeight: 250,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Hero(
                        tag: item.title,
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            border: Border.all(color: item.color, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: item.color.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Icon(item.icon, size: 50, color: item.color),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        item.title.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                                color: item.color.withOpacity(0.8),
                                blurRadius: 10)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface.withOpacity(0.9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // YANGI: Ko'rsatma rasmini joylashtirish
                      _buildInfoTag("Taktik Diagramma", item.color),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/instruction/${item.imageAsset}',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Agar rasm topilmasa yoki yuklanmasa, o'rniga Text ko'rsatiladi
                            return Container(
                              height: 150,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Center(
                                child: Text(
                                  "Rasm topilmadi: ${item.imageAsset}\n(Iltimos, rasmni 'assets/images/' papkasiga joylang)",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.redAccent, fontSize: 14),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildInfoTag("Tafsilot", item.color),
                      const SizedBox(height: 16),
                      Text(
                        item.description.trim(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.6,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.color.withOpacity(0.2),
                            foregroundColor: item.color,
                            side: BorderSide(color: item.color),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("Tushunarli"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
