import 'package:efinfo_beta/Others/positionskillchecker.dart';
import 'package:efinfo_beta/Others/teambuilder.dart';
import 'package:flutter/material.dart';

class Morepage extends StatefulWidget {
  const Morepage({super.key});

  @override
  State<Morepage> createState() => _MorepageState();
}

class _MorepageState extends State<Morepage> {
  @override
  Widget build(BuildContext context) {
    final List<_ListItem> items = [
      _ListItem(
        title: 'Skill moslik Hisoblagich',
        icon: "assets/images/skill_calculator.png",
        color: const Color(0xFF06DF5D),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PositionSkillPage()),
          );
        },
        // onBlock: true, // 🔒 bloklangan
      ),
      _ListItem(
        title: 'SuperSquad XI',
        icon: "assets/images/formations.png",
        color: const Color(0xFF06DF5D),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TeamBuilderScreen()),
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
          ],
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  final String icon;
  final Color color;
  final VoidCallback? onTap;
  final bool onBlock;

  const _ListItem({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
    this.onBlock = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBlock ? null : onTap, // 🔒 bosilmaydi
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
                          icon.toString(),
                          color: const Color(0xFF06DF5D),
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
    );
  }
}
