import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ElementsPage extends StatelessWidget {
  const ElementsPage({super.key});

  final List<Map<String, String>> elements = const [
    {
      'title': 'eFootball Coins',
      'description':
          'Premium valyuta. O\'yinchilar, murabbiylar va paketlarni sotib olish uchun ishlatiladi.',
      'details':
          "• **Nima uchun ishlatiladi?** O'yinchilar, murabbiylar, forma va paketlarni (packs) sotib olish uchun premium valyuta. Chance Deal yoki Nominating Contract orqali o'yinchilarni imzolashga sarflanadi.\n\n• **Qanday olish mumkin?** Kunlik login bonuslari, Match Pass (o'yinlar orqali), Objectives (vazifalar), eventlar, kampaniyalar va real pul bilan sotib olish.\n\n• **Muhim:** Eng qimmat va foydali valyuta.",
      'image': 'assets/images/elements/coins.png'
    },
    {
      'title': 'GP (Game Points)',
      'description':
          'Asosiy bepul valyuta. Reset progression va elementlarni almashtirish uchun.',
      'details':
          "• **Nima uchun ishlatiladi?** Player Progression'ni (o'yinchi statslarini) qayta tiklash (reset) uchun. Shuningdek, GP Exchange Shop'da Skill Token, Random Booster Token va boshqa buyumlarni almashtirish uchun sarflanadi.\n\n• **Qanday olish mumkin?** O'yinlar (matchlar), eventlar, kunlik bonuslar va vazifalar orqali.\n\n• **Maksimal miqdor:** 999,999,999.",
      'image': 'assets/images/elements/gp.png'
    },
    {
      'title': 'eFootball Points',
      'description':
          'Sodiqlik ballari. eFootball Point Shop\'da sovg\'alar olish uchun.',
      'details':
          "• **Nima uchun ishlatiladi?** Alohida eFootball Point Shop'da Coins, tokenlar yoki boshqa sovg'alar uchun almashtiriladi.\n\n• **Qanday olish mumkin?** eFootball seriyasidagi o'yinlarni o'ynash, esports musobaqalarini tomosha qilish va Konami ID bog'lash orqali.",
      'image': 'assets/images/elements/points.png'
    },
    {
      'title': 'Exp. Token',
      'description': 'O\'yinchilarni levelini oshirish uchun (Experience).',
      'details':
          "• **Nima uchun ishlatiladi?** O'yinchiga Experience Points (Exp) berib, uning darajasini (level) oshirish uchun. Daraja oshishi bilan Progression Points ochiladi.\n\n• **Qanday olish mumkin?** Eventlar, GP shop, login bonuslari va sovg'alar.",
      'image': 'assets/images/elements/exp_token.png'
    },
    {
      'title': 'Skill Token',
      'description': 'O\'yinchiga qo\'shimcha skill qo\'shish uchun.',
      'details':
          "• **Nima uchun ishlatiladi?** O'yinchiga tasodifiy qo'shimcha skill (qobiliyat) qo'shish uchun. Har bir o'yinchi uchun maksimal 5 ta qo'shimcha skill.\n\n• **Cheklovlar:** Random (tasodifiy) skill beradi.",
      'image': 'assets/images/elements/skill_token.png'
    },
    {
      'title': 'Advanced Skill Token',
      'description': 'O\'yinchiga kategoriyadan tasodifiy skill berish uchun.',
      'details':
          "**• Nima uchun ishlatiladi?** O'yinchiga 'Skill Training' bo'limida tanlangan kategoriyadan (Shooting, Passing, Dribbling, Defending, Boshqa) tasodifiy skill qo'shish uchun. Mavjud qo'shimcha skillni o'chirib (Delete Overwrite), yangi skill bilan almashtirish mumkin. O'yinchi pozitsiyasiga mos skills taklif etiladi (masalan, CF uchun GK skills yo'q).\n\n• Cheklovlar: Kategoriya ichida tasodifiy (to'liq skill tanlash mumkin emas); duplicate yoki keraksiz skill chiqishi mumkin; tabiiy (innate) skills o'chirib bo'lmaydi, faqat qo'shimcha skill ustida ishlaydi; 'Random Category' yoki 'Random' variantlari mavjud.",
      'image': 'assets/images/elements/advanced_skill_token.png'
    },
    {
      'title': 'Position Token',
      'description':
          'O\'yinchining yangi pozitsiyada o\'ynash qobiliyatini oshirish uchun.',
      'details':
          "• **Nima uchun ishlatiladi?** O'yinchining pozitsiya malakasini (Position Proficiency) tasodifiy 2 ta pozitsiyaga oshirish uchun (faqat mos o'yinchilar uchun).\n\n• **Cheklovlar:** Faqat 2 ta pozitsiya; barcha o'yinchilar uchun emas.",
      'image': 'assets/images/elements/position_token.png'
    },
    {
      'title': 'Random Booster Token',
      'description': 'O\'yinchiga tasodifiy Booster berish uchun.',
      'details':
          "• **Nima uchun ishlatiladi?** O'yinchiga tasodifiy Booster berish uchun (o'yinchi pozitsiyasiga mos 15 ta variantdan biri tanlanadi). Booster statslarni 99 dan oshiradi va Progression'ni kuchaytiradi.\n\n• **Cheklovlar:** Random; ba'zi o'yinchilar innate (tabiiy) boosterlarga ega.",
      'image': 'assets/images/elements/booster_token.png'
    },
    {
      'title': 'Select Booster Token',
      'description': 'Aniq Booster yaratish uchun (Crafting).',
      'details':
          "• **Nima uchun ishlatiladi?** Booster Crafting'da tanlangan Booster yaratish yoki faollashtirish uchun (double booster uchun ishlatiladi).\n\n• **Qanday olish mumkin?** Eventlar va sovg'alar.",
      'image': 'assets/images/elements/select_booster.png'
    },
    {
      'title': 'Nominating Contract',
      'description': 'Maxsus ro\'yxatdan o\'yinchi tanlash va imzolash uchun.',
      'details':
          "• **Nima uchun ishlatiladi?** Muayyan yulduz darajasidagi (3*, 4*, 5*) o'yinchilar ro'yxatidan o'zingizga keraklisini tanlab imzolash uchun.\n\n• **Muddati:** Olinganidan keyin 60 kun davomida ishlatilishi kerak.",
      'image': 'assets/images/elements/contract.png'
    },
    {
      'title': 'Standard Player Ticket',
      'description': 'Tasodifiy standart o\'yinchi imzolash uchun.',
      'details':
          "• **Nima uchun ishlatiladi?** Standart o'yinchilar bazasidan tasodifiy bitta o'yinchini tekinga olish uchun chipta.",
      'image': 'assets/images/elements/ticket.png'
    },
    {
      'title': 'Chance Deal',
      'description': 'O\'yinchiga tasodifiy o\'yinchi berish uchun.',
      'details':
          "• **Nima uchun ishlatiladi?** O'yinchiga tasodifiy o'yinchi imzolash uchun (Chance Deal paketidagi maxsus ro'yxatdan biri tanlanadi, odatda 50 tagacha o'yinchi, shu jumladan Epic yoki Showtime kartalar). Ko'pincha kampaniyalarda bepul beriladi va yuqori reytingli o'yinchilarni olish imkonini beradi.\n\n• **Cheklovlar:** Random; past reytingli (masalan, 1-3 yulduzli) o'yinchilar chiqishi mumkin, hatto Epic paketlarda ham; kafolat yo'q, ko'p spin (21-81 ta) kerak bo'lishi mumkin; ba'zi kampaniyalarda Selection Contract bilan birga beriladi.",
      'image': 'assets/images/elements/chance_deal.png'
    },
    {
      'title': 'Selection Contract',
      'description': 'O\'yinchiga tanlangan o\'yinchi berish uchun.',
      'details':
          "**• Nima uchun ishlatiladi?** O'yinchiga maxsus ro'yxatdan (odatda Epic, POTW yoki Showtime kartalar) bir o'yinchini tanlab imzolash imkonini beradi. Kampaniyalarda bepul yoki Chance Deal bilan birga beriladi va yuqori reytingli o'yinchilarni kafolatli olish uchun ishlatiladi.",
      'image': 'assets/images/elements/selection_contract.png'
    }
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
        elevation: 0,
        title: Text("eFootball Elements",
            style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: elements.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = elements[index];
          return GlassContainer(
            borderRadius: 16,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor:
                      isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (context) =>
                      _DetailPopup(item: item, isDark: isDark),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black12,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: item['image'] != null
                            ? Image.asset(item['image']!,
                                width: 30, height: 30, fit: BoxFit.cover)
                            : Icon(Icons.image,
                                color: isDark ? Colors.white38 : Colors.black38,
                                size: 30),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: GoogleFonts.outfit(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['description']!,
                            style: GoogleFonts.outfit(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: isDark ? Colors.white38 : Colors.black38),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailPopup extends StatelessWidget {
  final Map<String, String> item;
  final bool isDark;
  const _DetailPopup({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black12,
                      borderRadius: BorderRadius.circular(10)),
                  child: item['image'] != null
                      ? Image.asset(item['image']!,
                          width: 30, height: 30, fit: BoxFit.cover)
                      : Icon(Icons.image,
                          color: isDark ? Colors.white38 : Colors.black38,
                          size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item['title']!,
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildRichText(item['details']!, isDark),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06DF5D),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("Tushunarli",
                    style: GoogleFonts.outfit(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRichText(String text, bool isDark) {
    List<String> parts = text.split('**');
    List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        spans.add(TextSpan(
            text: parts[i],
            style: GoogleFonts.outfit(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 14,
                height: 1.5)));
      } else {
        spans.add(TextSpan(
            text: parts[i],
            style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.bold)));
      }
    }
    return RichText(text: TextSpan(children: spans));
  }
}
