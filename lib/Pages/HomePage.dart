import 'package:efinfo_beta/Player/player_skillspage.dart';
import 'package:efinfo_beta/Player/playingstylespage.dart';
import 'package:efinfo_beta/Player/positions.dart';
import 'package:flutter/material.dart';

import '../Player/playerStat.dart';
import '../components/newBadge.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final List<_GridItem> items = [
      _GridItem(
        badge: false,
        title: 'Playing Styles',
        subtitle: 'O\'yin stili',
        icon: "assets/images/playing_styles.png",
        color: const Color(0xFF06DF5D),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PlayingStylePage()),
          );
        },
      ),
      _GridItem(
        badge: false,
        title: 'Player Skills',
        subtitle: 'Futbolchi skillari',
        icon: "assets/images/soccer_shoe.png",
        color: const Color(0xFF06DF5D),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PlayerSkillsPage()),
          );
        },

        // onBlock: true, // 🔒 bloklangan
      ),
      _GridItem(
        badge: false,
        title: 'Positions',
        subtitle: 'Pozitsiyalar',
        icon: "assets/images/positions.png",
        color: const Color(0xFF06DF5D),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PositionsPage()),
          );
        },
        // onBlock: true, // 🔒 bloklangan
      ),
      _GridItem(
        badge: false,
        title: "Player stats",
        subtitle: "O'yinchi statistikasi",
        icon: "assets/images/details.png",
        color: const Color(0xFF06DF5D),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PlayerStatPage()),
          );
        },
        // onBlock: true, // 🔒 bloklangan
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF011A0B), //0xFF06DF5D
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => items[index],
            ),
            const SizedBox(
              height: 30,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.telegram_outlined, size: 32, color: Colors.blue),
                Text("@eFootball_Info_Hub",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF06DF5D),
                    )),
              ],
            ),
            const Text(
              textAlign: TextAlign.center,
              "Ilova hozirda ishlab chiqilmoqda, ko'proq ma'lumot uchun telegram kanalga obuna bo'ling",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const Text(
              "Versiya v1.0.6",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final VoidCallback? onTap;
  final bool onBlock;
  final bool badge;

  const _GridItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.badge,
    this.onTap,
    this.onBlock = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBlock ? null : onTap, // 🔒 bosilmaydi
      child: NewBadgeWrapper(
        showBadge: badge,
        child: Stack(
          children: [
            // Orqa fon
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: onBlock ? 0.5 : 1.0, // 🔒 blok bo‘lsa hiraroq
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 60,
                          child: Image.asset(
                            color: const Color(0xFF06DF5D),
                            icon.toString(),
                          )),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Opacity(
                        opacity: .7,
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 🔒 Agar block bo‘lsa lock icon
            if (onBlock)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color.fromARGB(45, 0, 0, 0)),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, color: Colors.white60, size: 40),
                      Text(
                        "Tez kunda...",
                        style: TextStyle(color: Colors.white60, fontSize: 16),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
