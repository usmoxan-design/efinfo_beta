import 'package:efinfo_beta/Pages/HomePage.dart';
import 'package:efinfo_beta/Pages/ManagerPage.dart';
import 'package:efinfo_beta/Pages/MorePage.dart';
import 'package:efinfo_beta/tournament/TournamentMaker.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Sahifalar ro‘yxati
  final List<Widget> _pages = const [
    HomePage(),
    ManagerPage(),
    TournamentListPage(),
    Morepage(),
  ];

  Future<void> _launchTelegram() async {
    final Uri url = Uri.parse('https://t.me/eFootball_Info_Hub');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
              child: Image.asset(
                'assets/images/mainLogo.png',
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 70,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: const BoxDecoration(
              color: AppColors.telegram, // Telegram rangi
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.telegram, color: Colors.white, size: 45),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "@eFootball_Info_Hub",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Kanalga obuna bo'ling",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _launchTelegram,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF229ED9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  child: const Text(
                    "Obuna bo'lish",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          Theme(
            // Navigatsiya satrini maxsus Theme bilan o'rash
            data: Theme.of(context).copyWith(
              // Matn rangini belgilash uchun labelTextStyle'ni o'zgartiramiz
              navigationBarTheme: NavigationBarThemeData(
                // Tanlanmagan (Inactive) matn uslubi
                labelTextStyle:
                    WidgetStateProperty.resolveWith<TextStyle>((states) {
                  if (states.contains(WidgetState.selected)) {
                    // Tanlangan matnni (Active) doim oq yoki boshqa bir rangda saqlash
                    return const TextStyle(
                        color: Color(0xFF06DF5D), fontSize: 12);
                  }
                  // Tanlanmagan matnni (Inactive) oq rangda, lekin biroz xira qilish
                  return const TextStyle(color: Colors.white70, fontSize: 12);
                }),
                // Ikonkalar uchun ham rangni bu yerda sozlash mumkin (avvalgi javobdagi kabi)
                iconTheme:
                    WidgetStateProperty.resolveWith<IconThemeData>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(color: AppColors.surface);
                  }
                  return const IconThemeData(color: Colors.white70);
                }),
              ),
            ),
            child: NavigationBar(
              // 1. Indikator rangi: Tanlangan tugma orqasidagi rang (Yashil)
              indicatorColor: AppColors.accent,

              // 2. Navigatsiya satri foni (To'q Yashil/Qora)
              backgroundColor: AppColors.surface,

              // 3. Ikonka va Matn Ranglari uchun Theme sozlamasi
              // Tanlanmagan (Inactive) elementlar Oq rangda bo'ladi
              // Tanlangan (Active) elementlar esa indicatorColor rangida bo'lishi kerak
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

              // Ikonka va Matn ranglarini boshqarish uchun qo'shimcha ThemeData
              // Buni MaterialApp/ThemeData da o'rnatish yaxshiroq, ammo bu yerda o'rnatish ham mumkin:

              /* // Agar ikonka va matn rangi indicatorColor bilan o'zgarmasa, quyidagicha qo'shimcha sozlanishi mumkin:
            surfaceTintColor: Colors.transparent, 
            indicatorShape: const RoundedRectangleBorder(),
            */

              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },

              destinations: const [
                NavigationDestination(
                  icon: Icon(
                    IonIcons.football,
                  ), // Tanlanmaganda biroz xira oq
                  selectedIcon: Icon(
                    IonIcons.football,
                  ), // Tanlanganda Yorqin Oq
                  label: "O'yinchi",
                ),
                NavigationDestination(
                  icon: Icon(IonIcons.school),
                  selectedIcon: Icon(IonIcons.school),
                  label: 'Menejer',
                ),
                NavigationDestination(
                  icon: Icon(IonIcons.trophy),
                  selectedIcon: Icon(IonIcons.trophy),
                  label: 'Turnirchi',
                ),
                NavigationDestination(
                  icon: Icon(EvaIcons.grid_outline),
                  selectedIcon: Icon(EvaIcons.grid),
                  label: "Boshqa",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
