import 'package:efinfo_beta/Pages/HomePage.dart';
import 'package:efinfo_beta/Pages/ManagerPage.dart';
import 'package:efinfo_beta/Pages/MorePage.dart';
import 'package:efinfo_beta/tournament/TournamentMaker.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(
          0xFF1A1A1A,
        ),
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
      bottomNavigationBar: Theme(
        // Navigatsiya satrini maxsus Theme bilan o'rash
        data: Theme.of(context).copyWith(
          // Matn rangini belgilash uchun labelTextStyle'ni o'zgartiramiz
          navigationBarTheme: NavigationBarThemeData(
            // Tanlanmagan (Inactive) matn uslubi
            labelTextStyle:
                WidgetStateProperty.resolveWith<TextStyle>((states) {
              if (states.contains(WidgetState.selected)) {
                // Tanlangan matnni (Active) doim oq yoki boshqa bir rangda saqlash
                return const TextStyle(color: Color(0xFF06DF5D), fontSize: 12);
              }
              // Tanlanmagan matnni (Inactive) oq rangda, lekin biroz xira qilish
              return const TextStyle(color: Colors.white70, fontSize: 12);
            }),
            // Ikonkalar uchun ham rangni bu yerda sozlash mumkin (avvalgi javobdagi kabi)
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFF1A1A1A));
              }
              return const IconThemeData(color: Colors.white70);
            }),
          ),
        ),
        child: NavigationBar(
          // 1. Indikator rangi: Tanlangan tugma orqasidagi rang (Yashil)
          indicatorColor: const Color(0xFF06DF5D),

          // 2. Navigatsiya satri foni (To'q Yashil/Qora)
          backgroundColor: const Color(0xFF1A1A1A),

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
    );
  }
}
