import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AiPlayingStyle {
  final String title;
  final String uzTitle;
  final String description;
  final IconData icon;
  final Color color;

  AiPlayingStyle({
    required this.title,
    required this.uzTitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class AiPlayingStylesPage extends StatelessWidget {
  const AiPlayingStylesPage({super.key});

  void _showDetails(BuildContext context, AiPlayingStyle style, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161616) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: style.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(style.icon, color: style.color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        style.title,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        style.uzTitle,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: const Color(0xFF06DF5D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.grey.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              "Batafsil ma'lumot:",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  style.description,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06DF5D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Tushunarli",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
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

    final List<AiPlayingStyle> styles = [
      AiPlayingStyle(
        title: "Trickster",
        uzTitle: "Fintchi",
        description:
            "To'p bilan chiroyli harakatlar qilib, \"step-over\" fintlari orqali raqibni aldab o'tish ustasi. Bu o'yinchi ko'pincha 1-ga-1 vaziyatlarda raqibni chalg'itish uchun murakkab harakatlardan foydalanadi.",
        icon: Icons.auto_fix_high_rounded,
        color: const Color(0xFF00CFFF),
      ),
      AiPlayingStyle(
        title: "Mazing Run",
        uzTitle: "Ajoyib dribling",
        description:
            "Nozik burilishlar va dribling yordamida raqib jarima maydonchasi ichkarisiga chuqur yorib kirishni yoqtiradigan o'yinchi. Bu uslubdagi o'yinchilar maydonning tor joylarida ham to'pni nazorat qila oladi.",
        icon: Icons.directions_run_rounded,
        color: const Color(0xFF06DF5D),
      ),
      AiPlayingStyle(
        title: "Speeding Bullet",
        uzTitle: "Tezkor o'q",
        description:
            "Tezlikka tayangan va doimo oldinga intilib, raqib himoyasini ortda qoldiradigan o'yinchi. Ochiq maydonda katta tezlik olib, qarshi hujumlarda juda xavfli hisoblanadi.",
        icon: Icons.bolt_rounded,
        color: const Color(0xFFFFA500),
      ),
      AiPlayingStyle(
        title: "Incisive Run",
        uzTitle: "Keskin yorib kirish",
        description:
            "Qanotlardan markazga qarab keskin kirib boradigan va gol urish uchun qulay vaziyat qidiradigan dribling ustasi. Odatda 'Inverted Winger'lar uchun xos uslub.",
        icon: Icons.call_made_rounded,
        color: const Color(0xFFFF453A),
      ),
      AiPlayingStyle(
        title: "Long Ball Expert",
        uzTitle: "Uzun paslar ustasi",
        description:
            "Maydonning istalgan nuqtasidan aniq va uzun uzatmalarni (long ball) amalga oshira oladigan o'yinchi. Uzoq masofadagi hujumchilarni topishda mahoratli.",
        icon: Icons.settings_input_component_rounded,
        color: const Color(0xFFA0A0A0),
      ),
      AiPlayingStyle(
        title: "Early Crosser",
        uzTitle: "Erta uzatma ustasi",
        description:
            "Maydonni juda yaxshi ko'radigan va qanotdan erta kross (uzatma) berish imkoniyatini hech qachon qo'ldan boy bermaydigan o'yinchi. Himoyachilar hali o'rnashib ulgurmasdan uzatmani amalga oshiradi.",
        icon: Icons.keyboard_double_arrow_right_rounded,
        color: const Color(0xFF00F294),
      ),
      AiPlayingStyle(
        title: "Long Ranger",
        uzTitle: "Uzoq masofadan zarba beruvchi",
        description:
            "Darvozadan ancha uzoq masofalardan kutilmagan va aniq zarbalar yo'llashni xush ko'radigan o'yinchi. Jarima maydonchasi tashqarisidan xavf tug'diradi.",
        icon: Icons.gps_fixed_rounded,
        color: const Color(0xFF229ED9),
      ),
    ];

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "AI Playing Styles",
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/pl_ai_stylepic.jpg', // Playing Style bilan bir xil rasm
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology_rounded,
                          color: const Color(0xFF06DF5D),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "AI Playing Styles nima?",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Bu uslublar AI'ning dribling, harakat va pas berish tendensiyasini o'zgartiradi, shuning uchun AI Division yoki VS AI o'yinlarida foydali. PvP'da (o'yinchi vs o'yinchi) siz qo'lda boshqarganingizda ular ishlamaydi.",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: styles.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final style = styles[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          style.title,
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark ? Colors.white : Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          style.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "O'zbekcha: ",
                          style: GoogleFonts.outfit(
                              color: const Color(0xFF06DF5D),
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFF06DF5D).withOpacity(0.1),
                            border: Border.all(
                                color:
                                    const Color(0xFF06DF5D).withOpacity(0.3)),
                          ),
                          child: Text(
                            style.uzTitle,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF06DF5D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF06DF5D),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () =>
                                _showDetails(context, style, isDark),
                            child: Text("Ko'proq o'qish",
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
