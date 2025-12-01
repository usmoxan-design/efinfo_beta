import 'dart:convert';
import 'package:efinfo_beta/models/positionsmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PositionsPage extends StatefulWidget {
  const PositionsPage({super.key});

  @override
  State<PositionsPage> createState() => _PositionsPageState();
}

class _PositionsPageState extends State<PositionsPage> {
  List<PositionsModel> playerPositions = [];
  List<PositionsModel> filteredPositions = [];
  @override
  void initState() {
    super.initState();
    loadPlayerPositions();
    print(filteredPositions.length);
  }

  Future<void> loadPlayerPositions() async {
    final String response =
        await rootBundle.loadString('assets/data/positions_list.json');
    final data = json.decode(response) as List;
    setState(() {
      playerPositions =
          data.map((item) => PositionsModel.fromJson(item)).toList();
      filteredPositions = playerPositions;
    });
  }

  void filterSearch(String query) {
    final results = playerPositions.where((style) {
      final titleLower = style.title.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower);
    }).toList();

    setState(() {
      filteredPositions = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Pozitsiyalar",
            // style: TextStyle(color: Colors.white),
          ),
          // backgroundColor: const Color(0xFF2E7BFF),
        ),
        body: playerPositions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/pl_positionpic.jpg',
                        ),
                      ),
                    ),
                    // 🔹 Search bar
                    // Padding(
                    //   padding:
                    //       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    //   child: TextField(
                    //     controller: searchController,
                    //     onChanged: filterSearch,
                    //     decoration: InputDecoration(
                    //       hintText: 'Qidirish...',
                    //       prefixIcon: const Icon(Icons.search),
                    //       filled: true,
                    //       fillColor: Colors.grey.shade200,
                    //       contentPadding: const EdgeInsets.symmetric(
                    //           vertical: 12, horizontal: 16),
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //         borderSide: BorderSide.none,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPositions.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final style = filteredPositions[index];

                        return GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => PlayerSkillsShow(
                            //       text: style.full_description,
                            //       image: style.image,
                            //       title: style.title,
                            //     ),
                            //   ),
                            // );
                          },
                          child: Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    color: Colors.black,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.asset(
                                        style.image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 8), // rasm bilan matn orasiga joy
                                  Expanded(
                                    // 🟢 Eng muhim qism
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          style.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          style.description,
                                          softWrap: true,
                                          overflow: TextOverflow
                                              .visible, // yoki ellipsis
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 6),
                                        // Align(
                                        //   alignment: Alignment.centerRight,
                                        //   child: ElevatedButton(
                                        //     style: ElevatedButton.styleFrom(
                                        //       backgroundColor:
                                        //           const Color(0xFF117340),
                                        //       foregroundColor: Colors.white,
                                        //       padding: const EdgeInsets.symmetric(
                                        //           horizontal: 24, vertical: 12),
                                        //       shape: RoundedRectangleBorder(
                                        //         borderRadius:
                                        //             BorderRadius.circular(8),
                                        //       ),
                                        //     ),
                                        //     onPressed: () {
                                        //       Navigator.push(
                                        //         context,
                                        //         MaterialPageRoute(
                                        //           builder: (context) =>
                                        //               const HomePage(),
                                        //         ),
                                        //       );
                                        //     },
                                        //     child: const Text("Ko'proq o'qish"),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ));
  }
}
