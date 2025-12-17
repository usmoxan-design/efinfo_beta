// import 'dart:convert';
// import 'package:efinfo_beta/Player/EfPlayerDetailsPage.dart';
// import 'package:efinfo_beta/theme/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class EfPlayersPage extends StatefulWidget {
//   const EfPlayersPage({super.key});

//   @override
//   State<EfPlayersPage> createState() => _EfPlayersPageState();
// }

// class _EfPlayersPageState extends State<EfPlayersPage> {
//   List<dynamic> players = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadPlayers();
//   }

//   Future<void> _loadPlayers() async {
//     try {
//       final String response =
//           await rootBundle.loadString('assets/data/mock_player.json');
//       final data = await json.decode(response);
//       setState(() {
//         if (data is List) {
//           players = data;
//         } else {
//           players = [data]; // Handle single object case if file reverts
//         }
//         isLoading = false;
//       });
//     } catch (e) {
//       debugPrint("Error loading players: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text("eFootBox", style: TextStyle(color: Colors.white)),
//         backgroundColor: AppColors.surface,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(onPressed: () {}, icon: const Icon(Icons.list)),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Filter bar placeholder
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: "Search",
//                 hintStyle: const TextStyle(color: Colors.white54),
//                 prefixIcon: const Icon(Icons.search, color: Colors.white54),
//                 filled: true,
//                 fillColor: AppColors.surface,
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide.none),
//               ),
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Row(
//               children: [
//                 _buildFilterChip("Filter"),
//                 _buildFilterChip("Sort"),
//                 _buildFilterChip("DT"),
//                 _buildFilterChip("2025 DP7.0", textColor: Colors.blueAccent),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           Expanded(
//             child: isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(color: AppColors.accent))
//                 : GridView.builder(
//                     padding: const EdgeInsets.all(8),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 3, // 3 columns like screenshot
//                       childAspectRatio: 0.65,
//                       mainAxisSpacing: 10,
//                       crossAxisSpacing: 10,
//                     ),
//                     itemCount: players.length,
//                     itemBuilder: (context, index) {
//                       final p = players[index];
//                       return _buildPlayerCard(p);
//                     },
//                   ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChip(String label, {Color? textColor}) {
//     return Container(
//       margin: const EdgeInsets.only(right: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(label,
//           style: TextStyle(
//               color: textColor ?? AppColors.accent,
//               fontWeight: FontWeight.bold)),
//     );
//   }

//   Widget _buildPlayerCard(Map<String, dynamic> player) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (_) => EfPlayerDetailsPage(playerData: player)),
//         );
//       },
//       child: Column(
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 // Card Art Background
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(4),
//                     image: DecorationImage(
//                       image: AssetImage(player['images']?['card'] ??
//                           'assets/images/115893.png'),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 // Overlay info (Mocking the Screenshot look)
//                 Positioned(
//                   top: 4,
//                   left: 4,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(player['rating'].toString(),
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               shadows: [
//                                 Shadow(color: Colors.black, blurRadius: 2)
//                               ])),
//                       Text(player['position'],
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                               shadows: [
//                                 Shadow(color: Colors.black, blurRadius: 2)
//                               ])),
//                     ],
//                   ),
//                 ),
//                 Positioned(
//                     bottom: 4,
//                     left: 0,
//                     right: 0,
//                     child: Center(
//                         // Star rating placeholder
//                         child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: List.generate(
//                           5,
//                           (index) => const Icon(Icons.star,
//                               color: Colors.yellow, size: 8)),
//                     )))
//               ],
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             player['name'],
//             textAlign: TextAlign.center,
//             style: const TextStyle(color: Colors.white70, fontSize: 11),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           )
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:efinfo_beta/Player/EfPlayerDetailsPage.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EfPlayersPage extends StatefulWidget {
  const EfPlayersPage({super.key});

  @override
  State<EfPlayersPage> createState() => _EfPlayersPageState();
}

class _EfPlayersPageState extends State<EfPlayersPage> {
  // 'List<dynamic>' o'rniga 'List<Map<String, dynamic>>' ishlatish xavfsizroq
  List<Map<String, dynamic>> players = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

// EfPlayersPage.dart faylida _loadPlayers() funksiyasini quyidagicha to'g'rilang:

  Future<void> _loadPlayers() async {
    try {
      // 1. Faylni String sifatida yuklash
      final String response =
          await rootBundle.loadString('assets/data/mock_player.json');

      // 2. Stringni List<dynamic> formatida dekodlash
      final dynamic data = json.decode(response);

      setState(() {
        if (data is List) {
          // Agar List bo'lsa, to'g'ri ishlaymiz
          players = data.cast<Map<String, dynamic>>();
          debugPrint(
              "✅ O'yinchilar List sifatida yuklandi. Son: ${players.length}");
        } else {
          // Agar kutilmagan format bo'lsa (Sizning holatingizda faqat Map)
          // Agar bu qism ishlasa, JSON formatida List qavslari [] dan oldin yoki keyin noto'g'ri belgi bor degani.
          players =
              []; // Bitta ob'ektni Listga kiritish o'rniga, xato bor deb hisoblaymiz
          debugPrint(
              "❌ JSON List emas. Kutilmagan format. (List qavslarini tekshiring)");
        }
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Xato: JSON yuklanmadi yoki noto'g'ri formatda: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("eFootBox", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.list)),
        ],
      ),
      body: Column(
        children: [
          // Filter bar placeholder
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _buildFilterChip("Filter"),
                _buildFilterChip("Sort"),
                _buildFilterChip("DT"),
                _buildFilterChip("2025 DP7.0", textColor: Colors.blueAccent),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent))
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    // Agar 'players' listi bo'sh bo'lsa, xabar ko'rsatish
                    itemCount: players.isEmpty ? 0 : players.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 columns like screenshot
                      childAspectRatio: 0.65,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final p = players[index];
                      return _buildPlayerCard(p);
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {Color? textColor}) {
    // ... avvalgi kod bilan bir xil
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: textColor ?? AppColors.accent,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> player) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EfPlayerDetailsPage(playerData: player)),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Card Art Background: Hamma uchun 115893.png ishlatiladi
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/115893.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Overlay info
                Positioned(
                  top: 4,
                  left: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(player['rating'].toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 2)
                              ])),
                      Text(player['position'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 2)
                              ])),
                    ],
                  ),
                ),
                Positioned(
                    bottom: 4,
                    left: 0,
                    right: 0,
                    child: Center(
                        // Star rating placeholder
                        child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                          5,
                          (index) => const Icon(Icons.star,
                              color: Colors.yellow, size: 8)),
                    )))
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            player['name'],
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
