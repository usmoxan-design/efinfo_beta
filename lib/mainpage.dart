import 'package:efinfo_beta/Pages/HomePage.dart';
import 'package:efinfo_beta/Pages/ManagerPage.dart';
import 'package:efinfo_beta/Pages/MorePage.dart';
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
    Morepage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 25,
              child: Image.asset(
                'assets/images/efootball-logo.png',
              ),
            ),
            const Text(' Info'),
            const SizedBox(width: 10),
            Container(
                padding: const EdgeInsets.only(
                    top: 5, bottom: 5, right: 10, left: 10),
                decoration: BoxDecoration(
                    color: const Color(0xFF117340),
                    borderRadius: BorderRadius.circular(99)),
                child: const Text(
                  'sinov',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )),
          ],
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(FontAwesome.futbol),
            selectedIcon: Icon(FontAwesome.futbol_solid),
            label: "O'yinchi",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_4_outlined),
            selectedIcon: Icon(Icons.person_4),
            label: 'Menejer',
          ),
          NavigationDestination(
            icon: Icon(EvaIcons.grid_outline),
            selectedIcon: Icon(EvaIcons.grid),
            label: "Boshqa",
          ),
        ],
      ),
    );
  }
}
