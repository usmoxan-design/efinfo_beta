import 'dart:convert';

import 'package:efinfo_beta/Others/markdown_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/mngr_plStyle.dart';

class ManagerStylesPage extends StatefulWidget {
  const ManagerStylesPage({super.key});

  @override
  State<ManagerStylesPage> createState() => _ManagerStylesPageState();
}

class _ManagerStylesPageState extends State<ManagerStylesPage> {
  List<PlayingStyle> playingStyles = [];
  List<PlayingStyle> filteredStyles = [];
  final TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadPlayingStyles();
  }

  Future<void> loadPlayingStyles() async {
    final String response =
        await rootBundle.loadString('assets/data/mngr_pl_styles.json');
    final data = json.decode(response) as List;
    setState(() {
      playingStyles = data.map((item) => PlayingStyle.fromJson(item)).toList();
      filteredStyles = playingStyles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manager Playing Styles",
          // style: TextStyle(color: Colors.white),
        ),
        // backgroundColor: const Color(0xFF2E7BFF),
      ),
      body: playingStyles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/manager_pl_styles.jpg',
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredStyles.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final style = filteredStyles[index];

                      return Card(
                        // color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(
                            style.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                style.description,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF117340), // fon rangi

                                      foregroundColor:
                                          Colors.white, // matn rangi

                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MarkdownPage(
                                            title: style.title,
                                            markdownPath: style.data,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text("Ko'proq o'qish"),
                                  ),
                                ],
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
