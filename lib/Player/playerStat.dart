import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerStatPage extends StatefulWidget {
  const PlayerStatPage({super.key});

  @override
  State<PlayerStatPage> createState() => _PlayerStatPageState();
}

class _PlayerStatPageState extends State<PlayerStatPage> {
  // --- Konfiguratsiya Ma'lumotlari ---
  // ... (Statistika va Tavsiflar o'zgarishsiz qoladi)

  final Map<String, int> playerStats = const {
    'Offensive Awareness': 93,
    'Ball Control': 94,
    'Dribbling': 90,
    'Tight Possession': 90,
    'Low Pass': 90,
    'Lofted Pass': 84,
    'Finishing': 90,
    'Header': 70,
    'Place Kicking': 68,
    'Curl': 75,
    'Defensive Awareness': 73,
    'Defensive Engagement': 77,
    'Tackling': 74,
    'Aggression': 77,
    'GK Awareness': 41,
    'GK Catching': 41,
    'GK Parrying': 41,
    'GK Reflexes': 41,
    'GK Reach': 41,
    'Speed': 90,
    'Acceleration': 90,
    'Kicking Power': 92,
    'Jump': 70,
    'Physical Contact': 80,
    'Balance': 86,
    'Stamina': 90,
  };

  final Map<String, String> statDescriptions = const {
    'Offensive Awareness':
        'Hujumkorlik ongi. Hujumda to\'pga tez reaksiya berish, himoyachilarni ortda qoldirib yugurish (through ball uchun), to\'g\'ri pozitsiyani egallash va paslarga yugurish qobiliyati. Misol: CF yoki SS uchun yuqori qiymat through ball\'larni offside bo\'lmasdan qabul qilishni ta\'minlaydi, raqib himoyasini buzishga yordam beradi.',
    'Ball Control':
        'To\'pni nazorat qilish. To\'pni qabul qilish (trapping), feintlar bajarish, birinchi teginish aniqligi va umumiy to\'pni ushlab turish qobiliyati. Misol: Noqulay kross yoki pasdan keyin to\'pni darhol boshqarish, dribling oldidan to\'g\'ri joylashtirish.',
    'Dribbling':
        'Dribling qilish. Yuqori tezlikda to\'p bilan harakatlanish, uni oyoq ostida ushlab turish, raqibni aldash va to\'pni yo\'qotmaslik qobiliyati. Speed va Acceleration bilan birgalikda ishlaydi. Misol: To\'liq yugurib dribling paytida to\'pni yaqin ushlab, raqibdan o\'tib ketish.',
    'Tight Possession':
        'Tor joyda to\'pni ushlab turish. Past tezlikda tor maydonlarda dribling, burilishlar bajarish, to\'pni oyoqqa yaqin ushlab turish va shielding (to\'pni himoya qilish) qobiliyati. Misol: Raqib bosimi ostida tor joyda burilib, to\'pni yo\'qotmasdan pas berish yoki zarba tayyorlash; 86+ qiymat tezroq burilish animatsiyasini ochadi.',
    'Low Pass':
        'Yerlatib pas berish. Yer bo\'ylab qisqa va o\'rta masofali paslar (through ball, oddiy paslar) aniqligi va tezligi. Misol: Tez hujumda jamoadoshga aniq pas berish, possession game\'da to\'pni saqlash.',
    'Lofted Pass':
        'Oshirib pas berish. Baland uzoq paslar, lofted through ball, chip pas va krosslarning aniqligi va tezligi. Misol: Orqa chiziqdan hujumchiga uzun pas, yoki long ball counter\'da tez o\'tish.',
    'Finishing':
        'Zarba berish aniqligi. Gol urish imkoniyatlarini yakunlash, birinchi zarba, noqulay pozitsiyalardagi zarbalar va stamina past bo\'lganda aniqlik. Misol: Noqulay burchakdan gol urish, yoki bosim ostida aniq zarba.',
    'Header':
        'Bosh bilan o\'ynash. Bosh bilan zarba berish, paslash yoki tozalashning aniqligi va kuchi. Hujum va himoyada ishlatiladi. Misol: Burchak to\'plaridan gol urish yoki krosslarni tozalash; Jump bilan birgalikda havodagi duelda muvaffaqiyat.',
    'Place Kicking':
        'Standart vaziyatlarni amalga oshirish. Jarima zarbalari (penalties) va erkin zarimalardagi (free kicks) aniqlik. Misol: To\'g\'ri masofadan jarima zarbasi urish yoki devor ustidan egri zarba.',
    'Curl':
        'To\'pni qayirish. Pas va zarbalar berishda to\'pga egri traektoriya (bend/curve) berish qobiliyati. Misol: Free kick\'dan devor atrofida egri zarba, yoki uzoq masofadan curler shot.',
    'Defensive Awareness':
        'Himoyaviy ong. Himoyada to\'pga tez reaksiya, raqib harakatlarini o\'qish, loose ball\'larga yugurish va to\'g\'ri pozitsiyani egallash. Misol: Raqib hujumini oldindan sezib, intercept qilish yoki bloklash; eng muhim himoya statistikasi.',
    'Tackling':
        'To\'pni olib qo\'yish. Stend taklinlar, sliding tackle va elka bilan urinishlarning muvaffaqiyati va aniqligi. Misol: Raqibdan to\'pni tozalab olish, foul berishdan saqlanish.',
    'Aggression':
        'Tajovuzkorlik. To\'p uchun kurashlarda itarish, tortish, press qilish va tez taklinlar tajovuzkorligi. Misol: Raqibni bosim ostiga olish.',
    'Defensive Engagement':
        'Himoyaviy ishtirok. To\'p jamoada bo\'lmaganda himoyaga qaytish, press qilish va jamoaviy himoyada faol bo\'lish tayyorligi va work rate. Misol: Hujumdan keyin tez himoyaga qaytib, raqib hujumini to\'xtatish.',
    'GK Awareness':
        'Darvozabon ongi. Darvozada to\'pga tez reaksiya, pozitsiyani to\'g\'ri tanlash va crosses/loose ball\'larga harakatlanish. Misol: Uzoq zarbalar uchun to\'g\'ri joylashib, seyv tayyorlash. (Maydon o\'yinchisi uchun past)',
    'GK Catching':
        'Darvozabon to\'p ushlash. Kuchli zarbalar va krosslarni ushlab qo\'yish, shotlarni zaiflashtirish qobiliyati. Misol: Powerful shotlarni to\'liq ushlab, rebound berishdan saqlanish. (Maydon o\'yinchisi uchun past)',
    'GK Parrying':
        'Darvozabon to\'p qaytarish. To\'pni xavfsiz joylarga parry qilish va otish qobiliyati. Misol: Uzoq zarbani tozalab, rebound gollarini oldini olish. (Maydon o\'yinchisi uchun past)',
    'GK Reflexes':
        'Darvozabon reflekslari. Yaqin masofadagi seyvlar uchun tez reaksiya. Misol: 1v1 yoki close range zarbalarni to\'xtatish. (Maydon o\'yinchisi uchun past)',
    'GK Reach':
        'Darvozabon yetkazuvchanligi. Darvozani qoplash va to\'pga yetib olish masofasi. Misol: Penalty\'larda kengroq seyv imkoniyati. (Maydon o\'yinchisi uchun past)',
    'Speed':
        'Tezlik. Maksimal yugurish tezligi. Harakat va driblingga ta\'sir qiladi. Misol: Orqa chiziqdan qochish yoki himoyachini ortda qoldirish.',
    'Acceleration':
        'Tezlanish. Turg\'undan tezlik yig\'ish va yuqori tezlikka tez chiqish. Misol: Qisqa masofada raqibni ortda qoldirish.',
    'Kicking Power':
        'Zarba kuchi. Zarba va paslarda to\'pga beriladigan maksimal kuch. Misol: Uzoq zarbalar uchun muhim.',
    'Jump':
        'Sakrash. Havodagi duelda balandlikka ko\'tarilish. Misol: Header\'larda ustunlik.',
    'Physical Contact':
        'Jismoniy aloqa. Yelka-yelka kurashlarda raqibga qarshi turish va to\'pni saqlash.',
    'Balance':
        'Muvozanat. To\'qnashuvlar va dribling paytida muvozanatni saqlash.',
    'Stamina':
        'Chidamlilik. Butun o\'yin davomida yuqori darajada ishlash va ikkinchi taymda pasaymaslik.',
  };

  final Map<String, String> _groupSubtitles = const {
    'ATTACKING': 'Hujum va to‘pni nazorat qilish mahorati',
    'ATHLETICISM': 'Jismoniy tayyorgarlik va harakat parametrlari',
    'DEFENDING': 'Raqib hujumlarini to‘xtatish qobiliyati',
    'GK STATS': 'Darvozabonlikka oid maxsus ko‘rsatkichlar',
  };

  static const String _onboardingKey = 'has_shown_stat_tutorial';

  @override
  void initState() {
    super.initState();
    // Sahifa yuklangandan keyin tutorialni tekshirish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTutorialStatus();
    });
  }

  // Tutorial holatini tekshirish
  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool(_onboardingKey) ?? false;

    if (!hasShown) {
      _showGeneralTutorialDialog(context);
      _setTutorialShown(); // Ko'rsatilgandan so'ng darhol saqlaymiz
    }
  }

  // Tutorialni ko'rsatgandan so'ng holatni saqlash
  Future<void> _setTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // --- Yangi, sodda umumiy tutorial dialogi ---
  void _showGeneralTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.blueGrey.shade900,
          title: const Text(
            '💡 Statistikalar Qanday Ishlaydi?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Bu sahifada futbolchining barcha statistik ko‘rsatkichlari keltirilgan.',
                  style: TextStyle(fontSize: 15, color: Colors.white70),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.yellow),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Har bir statistika nomi yonidagi (i) tugmasini bosing. Bu sizga o‘sha ko‘rsatkichning batafsil tushuntirishini ko‘rsatadi.',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Tushundim',
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- Qolgan funksiyalar (Avvalgi to'g'ri versiyadan olingan) ---

  Color _getStatColor(int statValue) {
    if (statValue >= 90) {
      return const Color(0xFF07FCF5);
    } else if (statValue >= 80) {
      return const Color(0xFF05fd07);
    } else if (statValue >= 65) {
      return const Color(0xFFfcaa04);
    } else {
      return const Color(0xFFd74233);
    }
  }

  void _showStatInfo(BuildContext context, String statName, int statValue) {
    Color statColor = _getStatColor(statValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: Text(
            statName,
            style: TextStyle(
              color: statColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  statDescriptions[statName] ??
                      'Bu statistika uchun ma\'lumot topilmadi.',
                  style: const TextStyle(
                      fontSize: 16, height: 1.5, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                // LinearProgressIndicator(
                //   value: statValue / 100,
                //   backgroundColor: Colors.grey[800],
                //   valueColor: AlwaysStoppedAnimation<Color>(statColor),
                //   minHeight: 10,
                // ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Tushundim',
                style: TextStyle(
                  color: statColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatGroupHeader(BuildContext context, String title) {
    String subtitle = _groupSubtitles[title] ?? '';

    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 8.0, left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      BuildContext context, String name, int value, int index) {
    Color statColor = _getStatColor(value);

    // Zebra effekti: toq indekslilar uchun ochroq fon
    Color rowBackgroundColor =
        index.isOdd ? const Color(0xFF212121) : const Color(0xFF121212);

    return Container(
      color: rowBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: GestureDetector(
        onTap: () => _showStatInfo(context, name, value),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      color: statColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 5),
                  // INFO IKONKASI
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: statColor, borderRadius: BorderRadius.circular(5)),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                value.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }

  // --- Asosiy Build funksiyasi ---
  @override
  Widget build(BuildContext context) {
    final List<String> attackingStats = [
      'Offensive Awareness',
      'Ball Control',
      'Dribbling',
      'Tight Possession',
      'Low Pass',
      'Lofted Pass',
      'Finishing',
      'Header',
      'Place Kicking',
      'Curl'
    ];
    final List<String> athleticismStats = [
      'Speed',
      'Acceleration',
      'Kicking Power',
      'Jump',
      'Physical Contact',
      'Balance',
      'Stamina'
    ];
    final List<String> defendingStats = [
      'Defensive Awareness',
      'Defensive Engagement',
      'Tackling',
      'Aggression'
    ];
    final List<String> gkStats = [
      'GK Awareness',
      'GK Catching',
      'GK Parrying',
      'GK Reflexes',
      'GK Reach'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'O\'yinchi statistikasi',
          // style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Asosiy Ma'lumotlar
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/player_stat.jpg',
                      ),
                    ),
                  ),
                  const Text(
                    'Demo Futbolchi Statistikasi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Overall Rating: 106',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF44B1FF),
                    ),
                  ),
                ],
              ),
            ),

            // Hujum statistikasi
            _buildStatGroupHeader(context, 'ATTACKING'),
            ...attackingStats.asMap().entries.map(
                  (entry) => _buildStatRow(context, entry.value,
                      playerStats[entry.value] ?? 0, entry.key),
                ),

            // Jismoniy va Harakat
            _buildStatGroupHeader(context, 'ATHLETICISM'),
            ...athleticismStats.asMap().entries.map(
                  (entry) => _buildStatRow(context, entry.value,
                      playerStats[entry.value] ?? 0, entry.key),
                ),

            // Himoya Statistikasi
            _buildStatGroupHeader(context, 'DEFENDING'),
            ...defendingStats.asMap().entries.map(
                  (entry) => _buildStatRow(context, entry.value,
                      playerStats[entry.value] ?? 0, entry.key),
                ),

            // Darvozabon Statistikasi
            _buildStatGroupHeader(context, 'GK STATS'),
            ...gkStats.asMap().entries.map(
                  (entry) => _buildStatRow(context, entry.value,
                      playerStats[entry.value] ?? 0, entry.key),
                ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
