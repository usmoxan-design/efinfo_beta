import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PackTricksPage extends StatelessWidget {
  const PackTricksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final List<Map<String, String>> tricks = [
      {
        "title": "3x Click Method",
        "desc":
            "Packga kirib, eng kuchli Epik kartasiga 3 marta tez bosib, keyin spin qilish."
      },
      {
        "title": "Cancel Glitch",
        "desc":
            "900 coinlik spinni bosib, 'Confirm' chiqanda 2 marta 'Cancel' qilib, 3-safar ochish."
      },
      {
        "title": "Low Rated Team",
        "desc":
            "Jamoangni kuchini (Team Strength) 1800-2000 dan past qilib qo'yib, keyin oching."
      },
      {
        "title": "Maintenance Timing",
        "desc":
            "Payshanba kungi obnovleniyadan keyin darhol (ilk 5 daqiqada) oching."
      },
      {
        "title": "00:00 UTC Method",
        "desc": "Server vaqti bilan tunda 00:00 yoki 03:00 da (UTC) oching."
      },
      {
        "title": "Standard Player Trick",
        "desc":
            "Oldin 1-2 ta oddiy (GP) o'yinchi sotib olib, keyin epik packni oching."
      },
      {
        "title": "Corner Click",
        "desc":
            "Packdagi 3 ta epik o'yinchini har birining burchagiga 1 martadan bosib chiqing."
      },
      {
        "title": "Profile Check",
        "desc":
            "Packni ochishdan oldin, 3 ta epikning stats (detail) menyusiga kirib, to'liq o'qib chiqing."
      },
      {
        "title": "Restart Game",
        "desc":
            "O'yinni to'liq yopib, qayta kirgandan keyin birdaniga (hech narsa qilmay) pack oching."
      },
      {
        "title": "Manager Change",
        "desc":
            "Trenerni (Manager) eng kuchsiz 1 yulduzliga o'zgartirib, keyin spin qiling."
      },
      {
        "title": "Base Card Release",
        "desc":
            "Keraksiz 1 yulduzli 3-4 ta o'yinchini 'Release' qilib, keyin packka kirib qiling."
      },
      {
        "title": "Animation Skip",
        "desc":
            "Spin bosgandan keyin ekran qorayishi bilan tezda 'Back' tugmasini bosib qiling."
      },
      {
        "title": "Full Squad",
        "desc":
            "My Team dagi o'yinchilar sonini to'ldirib (500/500), keyin 1 tasini bo'shatib oching."
      },
      {
        "title": "5 Second Hold",
        "desc":
            "Spin tugmasini bosib turganda 5 soniya sanab, keyin qo'yib yuboring."
      },
      {
        "title": "Japan Server Timing",
        "desc":
            "Vaqtni Tokio vaqtiga (JST) o'tkazib, u yerda soat 00:00 bo'lganda oching."
      },
      {
        "title": "Network Lag",
        "desc":
            "Wi-Fi ni o'chirib, 4G ga o'tgan zahoti spin qiling (Pling effekti)."
      },
      {
        "title": "Avatar Change",
        "desc":
            "User Settingsdan Avatar va Username'ni 'Konami' yoki 'Admin' deb o'zgartirib keyin oching."
      },
      {
        "title": "Training Trick",
        "desc":
            "Bitta o'yinchini 'Level Training' qilib, keyin omadni sinab ko'rish."
      },
      {
        "title": "Event Match",
        "desc":
            "Bitta vaqtincha (User Match) o'yin o'ynab, yutqazib (Forfeit) qilib, keyin oching."
      },
      {
        "title": "Free Try First",
        "desc":
            "Agar tekin 'Free Deal' bo'lsa, avval uni ochib, keyin coin ishlatib qiling."
      },
      {
        "title": "Store Visit",
        "desc":
            "Shop (eFootball Point) bo'limiga kirib, biror narsa ko'rib, keyin packka qaytib qiling."
      },
      {
        "title": "Alternate Click",
        "desc":
            "Eng kuchsiz va eng kuchli o'yinchini navbatma-navbat 5 marta bosib qiling."
      },
      {
        "title": "Music Off",
        "desc":
            "O'yin sozlamalaridan (Settings) musiqa va ovozni o'chirib qo'yib qiling."
      },
      {
        "title": "Language Change",
        "desc": "O'yin tilini yapon yoki xitoy tiliga o'tkazib oching."
      },
      {
        "title": "100 Coin Single",
        "desc":
            "900 lik emas, faqat 100 coinlik 'Single Spin' qilib, har safar 5 sekund kutiladi keyin ochiladi."
      },
      {
        "title": "Review Rating",
        "desc":
            "Play Marketda o'yinga 5 yulduz qo'yib, izoh yozib kelish (afsona)."
      },
    ];

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Pack Tricks",
          style: GoogleFonts.outfit(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "eFootball Mobile Pack Ochish Tricklari (Epic/Showtime uchun) ⚽️",
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF9500),
            ),
          ),
          const SizedBox(height: 20),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: tricks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildTrickItem(context, tricks[index], isDark);
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF06DF5D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFF06DF5D).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFFF9500), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Diqqat bular playerlarning tajribasi va superstition (irrim-sirim). Konami RNG (tasodif) ishlatadi, 100% kafolat yo'q! O'zingiz uchun saqlab qo'ying va sinab ko'ring.",
                    style: GoogleFonts.outfit(
                      color: isDark
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black87,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTrickItem(
      BuildContext context, Map<String, String> trick, bool isDark) {
    return GlassContainer(
      borderRadius: 16,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showTrickDetail(context, trick, isDark),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF06DF5D).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_fix_high,
                    color: Color(0xFF06DF5D), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  trick['title']!,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Icon(Icons.chevron_right,
                  color: isDark ? Colors.white54 : Colors.black38),
            ],
          ),
        ),
      ),
    );
  }

  void _showTrickDetail(
      BuildContext context, Map<String, String> trick, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.auto_fix_high,
                      color: Color(0xFF06DF5D), size: 28),
                  const SizedBox(width: 12),
                  Text(
                    trick['title']!,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Qanday qilish kerak:",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                trick['desc']!,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  height: 1.5,
                  color:
                      isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06DF5D),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Tushundim",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
