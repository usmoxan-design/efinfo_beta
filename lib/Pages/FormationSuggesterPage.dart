import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:efinfo_beta/models/formationsmodel.dart';
import 'package:efinfo_beta/data/formationsdata.dart';
import 'package:efinfo_beta/Player/formations_details.dart'; // For RealisticFieldPainter

// --- TOP-LEVEL TACTICAL HELPERS & DATA ---

const Map<String, String> _styleDescriptions = {
  'Possession Game':
      'Qisqa paslar va to\'p nazoratiga asoslangan uslub. Bo\'shliqlar yaratish uchun sabr bilan o\'yin quriladi va raqib himoyasi paslar orqali yorib o’tiladi.',
  'Quick Counter':
      'To\'pni qaytarib olgandan so\'ng darhol hujumga o\'tish. Tezkor yugurishlar va vertikal harakatlar orqali raqibni kutilmaganda ushlash asosiy maqsad.',
  'Long Ball Counter':
      'Himoyada zich turib, to\'pni egallagach raqib himoyasi orqasidagi bo\'shliqlarga uzun va aniq paslar bilan keskin hujumlar uyushtirish.',
  'Out Wide':
      'Qanot hujumchilari va himoyachilaridan foydalanish, krosslar va keng hujumlar orqali raqib himoyasini charchatish hamda bo’shatish.',
  'Long Ball':
      'Markazni chetlab o\'tib, jismoniy baquvvat hujumchilarga to\'g\'ridan-to\'g\'ri uzun paslar uzatish va ikkinchi to’p uchun kurashish.',
};

String _getUniversalPosition(String label) {
  String l = label.toUpperCase().trim();
  if (l == 'GK') return 'GK';
  if (l.contains('CB')) return 'CB';
  if (l == 'LB' || l == 'LWB' || l.contains('LB')) return 'LB';
  if (l == 'RB' || l == 'RWB' || l.contains('RB')) return 'RB';
  if (l.contains('DMF') || l.contains('CDM')) return 'DMF';
  if (l.contains('CMF') ||
      l.contains('LCM') ||
      l.contains('RCM') ||
      l.contains('CCM')) return 'CMF';
  if (l.contains('AMF') || l.contains('CAM')) return 'AMF';
  if (l.contains('LMF')) return 'LMF';
  if (l.contains('RMF')) return 'RMF';
  if (l.contains('LWF')) return 'LWF';
  if (l.contains('RWF')) return 'RWF';
  if (l.contains('SS')) return 'SS';
  if (l.contains('CF')) return 'CF';
  return label;
}

String _getRecommendedStyle(String uniPos, String managerStyle, int occurrence,
    List<String> allUniPos) {
  int totalPos = allUniPos.where((p) => p == uniPos).length;

  switch (uniPos) {
    case 'CF':
      if (totalPos == 1) {
        if (managerStyle == 'Possession Game') return 'Deep-Lying Forward';
        if (managerStyle == 'Long Ball') return 'Target Man';
        if (managerStyle == 'Out Wide') return 'Fox in the Box';
        return 'Goal Poacher';
      } else {
        // Synergy for 2+ CFs
        if (occurrence == 0) return 'Goal Poacher';
        if (occurrence == 1) {
          if (managerStyle == 'Long Ball' ||
              managerStyle == 'Long Ball Counter') return 'Target Man';
          if (managerStyle == 'Possession Game') return 'Deep-Lying Forward';
          return 'Fox in the Box';
        }
        return 'Goal Poacher';
      }
    case 'SS':
      if (managerStyle == 'Possession Game') return 'Deep-Lying Forward';
      if (managerStyle == 'Quick Counter') return 'Hole Player';
      return 'Creative Playmaker';
    case 'AMF':
      if (totalPos > 1) {
        if (occurrence == 0) return 'Hole Player';
        return 'Creative Playmaker';
      }
      if (managerStyle == 'Possession Game') return 'Creative Playmaker';
      if (managerStyle == 'Long Ball') return 'Classic No. 10';
      return 'Hole Player';
    case 'DMF':
      if (totalPos > 1) {
        if (occurrence == 0) return 'Anchor Man';
        return managerStyle == 'Possession Game'
            ? 'Orchestrator'
            : 'The Destroyer';
      }
      return 'Anchor Man';
    case 'CMF':
      if (totalPos > 1) {
        if (occurrence == 0) return 'Box-to-Box';
        if (occurrence == 1) return 'Orchestrator';
        return 'Hole Player';
      }
      return 'Box-to-Box';
    case 'CB':
      if (occurrence == 0) return 'Build Up';
      if (occurrence == 1) return 'The Destroyer';
      return 'Build Up';
    case 'GK':
      if (managerStyle == 'Possession Game' || managerStyle == 'Quick Counter')
        return 'Offensive Goalkeeper';
      return 'Defensive Goalkeeper';
    case 'LWF':
    case 'RWF':
      if (managerStyle == 'Out Wide') return 'Cross Specialist';
      if (managerStyle == 'Possession Game') return 'Creative Playmaker';
      return 'Prolific Winger';
    case 'LMF':
    case 'RMF':
      if (managerStyle == 'Out Wide') return 'Cross Specialist';
      if (managerStyle == 'Possession Game') return 'Roaming Flank';
      return 'Box-to-Box';
    case 'LB':
    case 'RB':
      if (managerStyle == 'Long Ball Counter' || managerStyle == 'Long Ball')
        return 'Defensive Full-back';
      return 'Attacking Full-back';
  }
  return 'Standard';
}

String _getStyleExplanation(String style) {
  Map<String, String> explanations = {
    'Goal Poacher':
        'Hujum chizig\'ida raqib himoyasi orqasiga yugurib kirish va gol urishga ixtisoslashgan.',
    'Deep-Lying Forward':
        'To\'pni olish uchun chuqurroq tushib, hujumni tashkil qilishga yordam beradi.',
    'Target Man':
        'Uzun paslarni qabul qilish, to\'pni ushlab turish va sheriklariga yetkazish uchun mo\'ljallangan.',
    'Creative Playmaker':
        'Hujumni tashkil etuvchi, ijodkor paslar beruvchi va bo\'shliqlar yaratuvchi o\'yinchi.',
    'Hole Player':
        'Hujumga o\'tilganda raqib jarima maydoniga yashirincha yugurib kiruvchi xavfli o\'yinchi.',
    'Orchestrator':
        'O\'yinni chuqurdan boshqaruvchi, paslar aniqligi va tempni nazorat qiluvchi usta.',
    'Anchor Man':
        'Himoya oldida mustahkam turib, raqib hujumlarini buzuvchi va pozitsiyasini tark etmaydigan himoyachi.',
    'Box-to-Box':
        'Maydonning har ikki tomonida (hujum va himoya) tinimsiz harakat qiladigan serg\'ayrat o\'yinchi.',
    'Build Up':
        'Himoyadan xotirjamlik bilan o\'yin quruvchi, paslar orqali hujumni boshlovchi markaziy himoyachi.',
    'The Destroyer':
        'Agressiv pressing va to\'pni ortib olish orqali raqibni to\'xtatishga ixtisoslashgan o\'yinchi.',
    'Offensive Goalkeeper':
        'Himoya ortidagi bo\'shliqlarni yopish uchun doim tayyor bo\'lgan va build-upda ishtirok etuvchi darvozabon.',
    'Defensive Goalkeeper':
        'O\'z chizig\'ida ishonchli turuvchi va asosan darvozani himoya qilishga e\'tibor qaratuvchi darvozabon.',
    'Prolific Winger':
        'Qanotdan markazga yorib kirib, darvozaga zarba berishni xush ko\'ruvchi hujumchi.',
    'Cross Specialist':
        'Qanotdan aniq va xavfli krosslar (to\'p uzatmalar) berish bo\'yicha mutaxassis.',
    'Roaming Flank':
        'Qanotdan markazga tez-tez ko\'chib turuvchi va pas almashishda faol o\'yinchi.',
    'Attacking Full-back':
        'Hujumga faol qo\'shiluvchi va qanotlarda son jihatdan ustunlik yaratuvchi himoyachi.',
    'Defensive Full-back':
        'Asosan himoyada qoluvchi va qanotlarni mustahkam yopadigan ishonchli himoyachi.',
    'Fox in the Box':
        'Jarima maydoni ichida to\'p kutilmaganda kelishini poylab turuvchi va bitta zarba bilan gol uruvchi "tulki" hujumchi.',
    'Classic No. 10':
        'Kam harakat qilib, faqat o\'z nuqtasidan turib ajoyib paslar va zarbalar beruvchi klassik pleymeyker.',
  };
  return explanations[style] ??
      'Ushbu uslub tanlangan taktikaga mukammal mos keladi.';
}

String? _getInstruction(String uniPos, String managerStyle) {
  if (uniPos == 'CF' && managerStyle == 'Possession Game') return 'False 9';
  if (uniPos == 'CF' &&
      (managerStyle == 'Quick Counter' || managerStyle == 'Long Ball Counter'))
    return 'Counter Target';
  if (uniPos.contains('WF') && managerStyle == 'Out Wide') return 'Anchoring';
  if (uniPos == 'DMF' &&
      (managerStyle == 'Quick Counter' || managerStyle == 'Long Ball Counter'))
    return 'Deep Line';
  if (uniPos.contains('LB') || uniPos.contains('RB')) {
    if (managerStyle == 'Possession Game' || managerStyle == 'Out Wide')
      return 'Attacking';
    if (managerStyle == 'Long Ball Counter') return 'Defensive';
  }
  return null;
}

String _getPositionBasedTask(String pos, String style) {
  switch (style) {
    case 'Offensive Goalkeeper':
      return "Zamonaviy 'Sweeper-Keeper' vazifasini bajaradi. Yuqori himoya chizig'i ortidagi bo'shliqlarni nazorat qiladi va build-upda 11-o'yinchi sifatida qisqa paslar bilan hujum boshlashga yordam beradi.";
    case 'Defensive Goalkeeper':
      return "Darvoza chizig'idagi ishonch asosi. U maydon tashqarisiga chiqishdan ko'ra, o'z chizig'ida qolishni va yaqin masofadan berilgan zarbalarni qaytarishni afzal ko'radi.";
    case 'Build Up':
      return "Himoyadan hujumga o'tishda 'konstruktor' vazifasini bajaradi. Markazda xotirjamlik bilan pas almashadi va qulay imkoniyat bo'lishi bilan vertikal paslar orqali hujumni tezlashtiradi.";
    case 'The Destroyer':
      return "Raqib hujumchilari uchun haqiqiy dushman. Agressiv pressing qiladi, jismoniy kurashga kirishadi va to'pni darhol olib qo'yib, jamoasini qarshi hujumga chiqaradi.";
    case 'Anchor Man':
      return "Himoyaning markaziy qismi oldidagi mustahkam qalqon. O'z pozitsiyasini tark etmaydi, raqibning pleymeykerlarini mahkam ushlaydi va hujumni buzib, birinchi pasni eng yaqin jamoadoshiga uzatadi.";
    case 'Orchestrator':
      return "Maydonning markaziy qismida o'yin 'dirijyori'. To'pni o'zida saqlash, o'yin tempini nazorat qilish va kutilmagan diagonal paslar bilan hujum yo'nalishini o'zgartirish uning asosiy ishi.";
    case 'Box-to-Box':
      return "Tinim bilmas 'dvigatel'. 90 daqiqa davomida ham o'z jarima maydonida himoyalanishda, ham raqib darvozasi oldida hujumni yakunlashda faol ishtirok etadi.";
    case 'Hole Player':
      return "Raqib himoyasidagi 'yashirin qurol'. Hujum boshlanishi bilan bo'shliqlar orasidan yashirincha yugurib kiradi va kutilmagan nuqtalarda paydo bo'lib, xavfli vaziyatlar yaratadi.";
    case 'Creative Playmaker':
      return "Jamoaning 'miyasi'. Raqib zich himoyasini yorib o'tish uchun ijodiy paslar beradi, to'pni o'zida ushlab turadi va qisqa masofada devor o'yinlari (1-2) tashkil qiladi.";
    case 'Classic No. 10':
      return "Klassik '10-raqam'. Kam harakat qilsa ham, to'p unga kelganda birgina sehrli pas yoki aniq zarba bilan o'yin taqdirini hal qila oladi.";
    case 'Goal Poacher':
      return "Doimo offsayd chizig'ida raqib himoyachilarini xavotirda ushlaydi. Minimal teginish bilan gol urishga intiladi va bo'shliq paydo bo'lishi bilan tezlikda yorib kiradi.";
    case 'Deep-Lying Forward':
      return "Hujum va yarim himoya o'rtasidagi asosiy bog'lovchi. Pastroqqa tushib to'p qabul qiladi va Jamoadoshlari (LWF/RWF) uchun bo'sh bo'shliqlar yaratib beradi.";
    case 'Fox in the Box':
      return "Jarima maydoni ichidagi 'tulki'. Ko'p yugurmaydi, lekin to'p qa yerga kelishini oldindan sezadi va har qanday kutilmagan vaziyatdan gol chiqarishga qodir.";
    case 'Target Man':
      return "Hujum markazidagi asosiy 'ustun'. Uzun paslarni ko'kragi yoki boshi bilan to'xtatib, Jamoadoshlariga yetkazib beradi va jismoniy kuchi bilan himoyachilarni band qilib turadi.";
    case 'Prolific Winger':
      return "Qanotdan ichkariga yorib kiruvchi hujumchi. Tezlikdan foydalanadi, dribling qiladi va qulay vaziyat tug'ilishi bilan darhol zarba berishga harakat qiladi.";
    case 'Cross Specialist':
      return "Qanotdagi 'snayper'. Uning asosiy vazifasi — jarima maydoni ichidagi CF larga zargardona aniqlikdagi krosslar (uzatmalar) yetkazib berish.";
    case 'Roaming Flank':
      return 'Qanot hujumchisi bo\'lsada, doim markazga ko\'chib turadi. Pas almashishlarda faol qatnashadi va kutilmagan nuqtalardan hujumga qo\'shiladi.';
    case 'Attacking Full-back':
      return "Zamonaviy hujumkor himoyachi. Doim qanot bo'ylab oldinga chiqadi, Jamoadoshlariga qanotda son jihatdan ustunlik yaratadi va hujumga qo'shimcha kenglik beradi.";
    case 'Defensive Full-back':
      return "Himoyadagi ishonchli devor. Hujumga deyarli chiqmaydi, o'z hududini mahkam yopadi va raqib qanot hujumchilariga joy bermaydi.";
    default:
      return "O'z pozitsiyasida jamoaviy ko'rsatmalarga asosan harakat qiladi va umumiy balansni saqlab turadi.";
  }
}

// --- PAGE WIDGETS ---

class FormationSuggesterPage extends StatefulWidget {
  const FormationSuggesterPage({super.key});

  @override
  State<FormationSuggesterPage> createState() => _FormationSuggesterPageState();
}

class _FormationSuggesterPageState extends State<FormationSuggesterPage> {
  String _selectedStyle = 'Possession Game';

  final List<String> _managerStyles = [
    'Possession Game',
    'Quick Counter',
    'Long Ball Counter',
    'Out Wide',
    'Long Ball'
  ];

  List<Formation> _suggestedFormations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = false;
      _generateSuggestions();
    });
  }

  void _generateSuggestions() {
    List<Formation> suggestions = [];
    switch (_selectedStyle) {
      case 'Possession Game':
        suggestions = allFormations
            .where((f) => [
                  '4-3-3',
                  '4-2-3-1',
                  '4-3-2-1',
                  '4-1-2-1-2',
                  '4-1-4-1',
                  '3-2-4-1'
                ].contains(f.name))
            .toList();
        break;
      case 'Quick Counter':
        suggestions = allFormations
            .where((f) => [
                  '4-2-1-3',
                  '4-1-2-3',
                  '4-2-2-2',
                  '5-2-1-2',
                  '4-3-3',
                  '4-2-4'
                ].contains(f.name))
            .toList();
        break;
      case 'Long Ball Counter':
        suggestions = allFormations
            .where((f) => [
                  '5-3-2',
                  '5-2-1-2',
                  '4-2-2-2',
                  '4-3-1-2',
                  '4-4-2',
                  '5-2-2-1'
                ].contains(f.name))
            .toList();
        break;
      case 'Out Wide':
        suggestions = allFormations
            .where((f) => [
                  '4-3-3',
                  '4-4-2',
                  '3-5-2',
                  '4-2-3-1',
                  '3-4-3',
                  '3-2-3-2'
                ].contains(f.name))
            .toList();
        break;
      case 'Long Ball':
        suggestions = allFormations
            .where((f) => ['4-4-2', '5-3-2', '3-5-2', '5-2-1-2', '3-1-4-2']
                .contains(f.name))
            .toList();
        break;
    }
    setState(() {
      _suggestedFormations = suggestions.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Tavsiya Etilgan Taktikalar",
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderDescription(isDark),
                        const SizedBox(height: 32),
                        Text(
                          "O'yin Uslubini Tanlang",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStyleChips(isDark),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tavsiya Etilgan Sxemalar",
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${_suggestedFormations.length} ta sxema",
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                if (_suggestedFormations.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState(isDark))
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildFormationCard(
                            _suggestedFormations[index], isDark),
                        childCount: _suggestedFormations.length,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: _buildResetButton(isDark),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderDescription(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF06DF5D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Color(0xFF06DF5D), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedStyle, // Return English name directly
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "Tanlangan o'yin uslubi",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFF06DF5D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _styleDescriptions[_selectedStyle]!,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleChips(bool isDark) {
    return Container(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _managerStyles.length,
        itemBuilder: (context, index) {
          final style = _managerStyles[index];
          bool isSelected = _selectedStyle == style;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStyle = style;
                  _generateSuggestions();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF06DF5D)
                      : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF06DF5D)
                        : Colors.transparent,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF06DF5D).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    style, // Use English name
                    style: GoogleFonts.outfit(
                      color: isSelected
                          ? Colors.black
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormationCard(Formation formation, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Mini Pitch
                Container(
                  width: 110,
                  height: 130,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06DF5D).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF06DF5D).withOpacity(0.1),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomPaint(
                      painter: RealisticFieldPainter(
                        positions: formation.positions,
                        playerRadius: 3.5,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formation.name,
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          _buildFullGuideButton(formation),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getFormationHint(formation.name),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 14,
                              color: isDark ? Colors.white38 : Colors.black38),
                          const SizedBox(width: 4),
                          Text(
                            "Taktik rollarni ko'rish",
                            style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, thickness: 0.5),
            ),
            // Roles - Sequential Card Layout
            Container(
              height: 75,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: formation.positions.length,
                itemBuilder: (context, index) {
                  return _buildPositionRoleCard(formation, index, isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullGuideButton(Formation formation) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormationDetailedGuidePage(
              formation: formation,
              managerStyle: _selectedStyle,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF06DF5D).withOpacity(0.1),
        foregroundColor: const Color(0xFF06DF5D),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: const Color(0xFF06DF5D).withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Qo'llanma",
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildPositionRoleCard(Formation formation, int index, bool isDark) {
    final labels = formation.labels ?? [];
    final List<String> uniLabels =
        labels.map((l) => _getUniversalPosition(l)).toList();
    Map<String, int> counts = {};

    // We need to pre-calculate counts up to the current index
    for (int i = 0; i <= index; i++) {
      String label = i < labels.length ? labels[i] : 'POS';
      String uniLabel = _getUniversalPosition(label);
      int occurrence = counts[uniLabel] ?? 0;
      counts[uniLabel] = occurrence + 1;
    }

    String label = index < labels.length ? labels[index] : 'POS';
    String uniLabel = _getUniversalPosition(label);
    int currentOccurrence = (counts[uniLabel] ?? 1) - 1;

    String style = _getRecommendedStyle(
        uniLabel, _selectedStyle, currentOccurrence, uniLabels);
    String? instruction = _getInstruction(uniLabel, _selectedStyle);

    return GestureDetector(
      onTap: () => _showStyleInfo(uniLabel, style, instruction, isDark),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Stack(
          children: [
            // Style accent background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF06DF5D).withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    uniLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF06DF5D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    style,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  if (instruction != null)
                    Icon(Icons.bolt,
                        size: 10, color: Colors.orangeAccent.withOpacity(0.8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStyleInfo(
      String pos, String style, String? instruction, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("$pos: $style",
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: AppColors.accentBlue)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getStyleExplanation(style),
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 16),
              Divider(
                  color: isDark ? Colors.white12 : Colors.black12,
                  thickness: 1),
              const SizedBox(height: 12),
              Text(
                "Vazifasi:",
                style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGreen),
              ),
              const SizedBox(height: 4),
              Text(
                _getPositionBasedTask(pos, style),
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.5),
              ),
              if (instruction != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.settings_suggest_rounded,
                        size: 14, color: Colors.orangeAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Tavsiya: $instruction",
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.orangeAccent,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tushunarli",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  String _getFormationHint(String name) {
    Map<String, String> hints = {
      '4-3-3': 'Qanot hujumlari va markaz nazorati uchun eng ideal balans.',
      '4-2-3-1':
          'Zich yarim himoya va ijodkor AMF orqali o\'yin qurish uchun qulay.',
      '4-3-2-1':
          'Markazdagi 5 kishi orqali Possession Game o\'yinida mutlaq ustunlik beradi.',
      '5-2-1-2':
          'Mustahkam himoya va AMF orqali keskin qarshi hujumlar uchun mo\'ljallangan.',
      '4-4-2':
          'Klassik uslub, ikki hujumchi bilan to\'g\'ridan-to\'g\'ri hujumlar uchun mos.',
      '4-2-2-2':
          'Ikkita AMF va ikkita CF bilan eng hujumkor meta sxemalardan biri.',
      '3-2-4-1':
          'Markazni to\'liq egallash va qanotlarni ham nazorat qilish imkonini beradi.',
    };
    return hints[name] ??
        'Ushbu sxema $_selectedStyle uslubini eng yaxshi ochib beradi.';
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text("Ushbu uslub uchun sxemalar topilmadi.",
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.white38 : Colors.black38))));
  }

  Widget _buildResetButton(bool isDark) {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Center(
            child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedStyle = 'Possession Game';
                    _generateSuggestions();
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text("Tiklash",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                style:
                    TextButton.styleFrom(foregroundColor: Colors.redAccent))));
  }
}

class FormationDetailedGuidePage extends StatelessWidget {
  final Formation formation;
  final String managerStyle;

  const FormationDetailedGuidePage(
      {super.key, required this.formation, required this.managerStyle});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("${formation.name} Qo'llanmasi",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildQuickSummary(isDark),
            const SizedBox(height: 24),
            _buildHowToPlaySection(isDark),
            const SizedBox(height: 24),
            _buildDoAndDontSection(isDark),
            const SizedBox(height: 24),
            _buildRoleVazifalari(isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSummary(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: AppColors.accentBlue, size: 24),
              const SizedBox(width: 10),
              Text(
                managerStyle,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _styleDescriptions[managerStyle]!,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToPlaySection(bool isDark) {
    String strategy = "";
    if (managerStyle == 'Possession Game') {
      strategy =
          "• Bir-ikki (1-2) paslardan foydalaning.\n• Cho'zib o'ynamang, driblingga berilmang.\n• Orchestrator orqali o'yinni qanotlarga burib turing.\n• Jarima maydoni atrofida 'Deep-Lying Forward' bilan devor o'yini qiling.";
    } else if (managerStyle == 'Quick Counter') {
      strategy =
          "• To'pni olgach darhol oldinga, Hole Player larga uzating.\n• Agressiv pressing qiling, lekin CB larni oldinga chiqarmang.\n• Tezkor paslar bering, raqib himoyasi tartibga tushishiga yo'l qo'ymang.";
    } else {
      strategy =
          "• Himoyada zich turing (Deep Line).\n• Uzun paslar bilan CF ni qidiring.\n• Raqib xatosini kuting va bitta aniq zarba bilan o'yinni hal qiling.";
    }

    return _buildCardWrapper(
        "Qanday o'ynash kerak?", strategy, Icons.sports_soccer_rounded, isDark);
  }

  Widget _buildDoAndDontSection(bool isDark) {
    return Column(
      children: [
        _buildSmallSection(
            "Nima qilish kerak (G'alaba kaliti):",
            [
              "Doim mini-kartaga qarab o'yinchilar joylashuvini tekshiring.",
              "Kerakli vaqtda 'Dash-cancel' ishlating.",
              "Darvozabon bilan build-up da ishtirok eting.",
              "Charchagan o'yinchilarni 60-daqiqada almashtiring (Super-sub kiritish)."
            ],
            Colors.greenAccent,
            isDark),
        const SizedBox(height: 16),
        _buildSmallSection(
            "Nima qilmaslik kerak (Mag'lubiyat sababi):",
            [
              "O'yin oxirigacha sprint (dash) tugmasini bosib turmang.",
              "CB ni raqib hujumchisiga qarshi asossiz oldinga tashlamang.",
              "Faqat bitta qanotdan hujum qilmang, o'yinni o'zgartirib turing.",
              "Pressing qilishda yarim himoyachilarni pozitsiyasidan haddan tashqari uzoqlashtirmang."
            ],
            Colors.redAccent,
            isDark),
      ],
    );
  }

  Widget _buildRoleVazifalari(bool isDark) {
    final labels = formation.labels ?? [];
    final List<String> uniLabels =
        labels.map((l) => _getUniversalPosition(l)).toList();
    Map<String, int> counts = {};

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("O'yinchilar vazifasi (Batafsil)",
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentGreen)),
          const SizedBox(height: 20),
          ...List.generate(formation.positions.length, (index) {
            String label = index < labels.length ? labels[index] : 'POS';
            String uniLabel = _getUniversalPosition(label);
            int occurrence = counts[uniLabel] ?? 0;
            counts[uniLabel] = occurrence + 1;
            String style = _getRecommendedStyle(
                uniLabel, managerStyle, occurrence, uniLabels);
            String? instruction = _getInstruction(uniLabel, managerStyle);

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.accentGreen.withOpacity(0.3)),
                        ),
                        child: Text(
                          uniLabel,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        style,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getPositionBasedTask(uniLabel, style),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  if (instruction != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.settings_suggest_rounded,
                              size: 14, color: Colors.orangeAccent),
                          const SizedBox(width: 6),
                          Text(
                            "Qo'shimcha tavsiya: $instruction",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.orangeAccent,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (index < formation.positions.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Divider(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                          thickness: 1),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCardWrapper(
      String title, String content, IconData icon, bool isDark) {
    return GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: AppColors.accentBlue, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black))
          ]),
          const SizedBox(height: 12),
          Text(content,
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.6)),
        ]));
  }

  Widget _buildSmallSection(
      String title, List<String> items, Color color, bool isDark) {
    return GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.outfit(
                  fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("• ",
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.bold)),
                Expanded(
                    child: Text(item,
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black87))),
              ]))),
        ]));
  }
}
