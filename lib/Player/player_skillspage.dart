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
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
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
