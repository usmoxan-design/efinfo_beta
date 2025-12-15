import 'package:efinfo_beta/Player/SkillTabs.dart';
import 'package:flutter/material.dart';

class PlayerSkillsPage extends StatefulWidget {
  const PlayerSkillsPage({super.key});
  @override
  State<PlayerSkillsPage> createState() => _PlayerSkillsPageState();
}

class _PlayerSkillsPageState extends State<PlayerSkillsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Skills'),
        bottom: TabBar(
          indicatorColor: Color(0xFF00C853),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          controller: _tabController,
          tabs: const [
            Tab(text: 'Oddiy skillar'),
            Tab(text: 'Noyob skillar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TabOne(),
          TabTwo(),
        ],
      ),
    );
  }
}
