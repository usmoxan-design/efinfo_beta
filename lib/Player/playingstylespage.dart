import 'dart:convert';

import 'package:efinfo_beta/Others/markdown_page.dart';
import 'package:efinfo_beta/models/playing_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayingStylePage extends StatefulWidget {
  const PlayingStylePage({super.key});

  @override
  State<PlayingStylePage> createState() => _PlayingStylePageState();
}

class _PlayingStylePageState extends State<PlayingStylePage> {
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
        await rootBundle.loadString('assets/data/playing_styles.json');
    final data = json.decode(response) as List;
    setState(() {
      playingStyles = data.map((item) => PlayingStyle.fromJson(item)).toList();
      filteredStyles = playingStyles;
    });
  }

  void filterSearch(String query) {
    final results = playingStyles.where((style) {
      final titleLower = style.title.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower);
    }).toList();

    setState(() {
      filteredStyles = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Playing Styles",
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
                        'assets/images/pl_stylepic.jpg',
                      ),
                    ),
                  ),
                  // 🔹 Search bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: TextField(
                      controller: searchController,
                      onChanged: filterSearch,
                      decoration: InputDecoration(
                        hintText: 'Qidirish...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        // fillColor: Colors.grey.shade200,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
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
                              const Text(
                                "Mos pozitsiyalar: ",
                                style: TextStyle(
                                    color: Color(0xFF117340),
                                    fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.green,
                                ),
                                child: Text(
                                  style.compatiblePositions,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              // const Spacer(),
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
