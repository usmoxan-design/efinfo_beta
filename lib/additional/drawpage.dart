// // import 'package:flutter/material.dart';

// // import '../Pages/TournamentMaker.dart';

// // class DrawPage extends StatefulWidget {
// //   const DrawPage({super.key, required this.items});
// //   final List<ItemModel> items;

// //   @override
// //   State<DrawPage> createState() => _DrawPageState();
// // }

// // class _DrawPageState extends State<DrawPage>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _controller;
// //   late Animation<Offset> _slideAnimation;
// //   late Animation<double> _opacityAnimation;
// //   late List<ItemModel> randomizedItems;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _shuffleItems();
// //     _controller = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 900),
// //     );

// //     _slideAnimation = Tween<Offset>(
// //       begin: const Offset(0, 1),
// //       end: const Offset(0, 0),
// //     ).animate(_controller);

// //     _opacityAnimation = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(_controller);

// //     _controller.forward();
// //   }

// //   void _shuffleItems() {
// //     randomizedItems = List.from(widget.items);
// //     randomizedItems.shuffle();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Tanlab olish/Qura"),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.shuffle),
// //             onPressed: () {
// //               setState(() {
// //                 _shuffleItems();
// //               });
// //             },
// //           ),
// //         ],
// //       ),
// //       body: Container(
// //         padding: const EdgeInsets.all(8),
// //         width: double.infinity,
// //         // color: const Color(0xFF010101),
// //         child: Column(children: [
// //           Expanded(
// //               child: SlideTransition(
// //                   position: _slideAnimation,
// //                   child: FadeTransition(
// //                     opacity: _opacityAnimation,
// //                     child: ListView.builder(
// //                       itemCount: randomizedItems.length,
// //                       itemBuilder: (context, index) {
// //                         if (index.isOdd) {
// //                           return const SizedBox.shrink();
// //                         }

// //                         // Extract pairs for display
// //                         ItemModel firstItem = randomizedItems[index];
// //                         ItemModel secondItem = randomizedItems[index + 1];

// //                         return _buildItemPair(firstItem, secondItem, index);
// //                       },
// //                     ),
// //                   )))
// //         ]),
// //       ),
// //     );
// //   }

// //   Widget _buildItemPair(ItemModel firstItem, ItemModel secondItem, int count) {
// //     return Container(
// //       margin: const EdgeInsets.only(top: 4, bottom: 4),
// //       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
// //       clipBehavior: Clip.antiAlias,
// //       decoration: ShapeDecoration(
// //         // color: const Color(0xFF161616),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(15),
// //         ),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         mainAxisAlignment: MainAxisAlignment.start,
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.all(8),
// //             decoration: const BoxDecoration(
// //               color: Colors.black,
// //             ),
// //             child: Center(child: Text("${count + 1}\n-\n${count + 2}")),
// //           ),
// //           const SizedBox(width: 10),
// //           Column(
// //             mainAxisSize: MainAxisSize.min,
// //             mainAxisAlignment: MainAxisAlignment.start,
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               _buildItemTile(firstItem),
// //               const SizedBox(height: 10),
// //               const SizedBox(height: 10),
// //               _buildItemTile(secondItem),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildItemTile(ItemModel item) {
// //     return Text(
// //       item.text,
// //       textAlign: TextAlign.center,
// //       style: const TextStyle(
// //         color: Colors.black,
// //         fontSize: 20,
// //         fontWeight: FontWeight.w400,
// //         height: 0,
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }
// // }















// ///////////////////2chisi
// import 'package:efinfo_beta/tournament/tournament_model.dart';
// import 'package:flutter/material.dart';
// import 'dart:math';

// class DrawPage extends StatefulWidget {
//   final List<PlayerModel> items;
//   final String tournamentName;

//   const DrawPage(
//       {super.key, required this.items, required this.tournamentName});

//   @override
//   State<DrawPage> createState() => _DrawPageState();
// }

// class _DrawPageState extends State<DrawPage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _opacityAnimation;
//   late List<PlayerModel> randomizedItems;

// @override
// void initState() {
//   super.initState();
//   // 1. Controller ni init qiling
//   _controller = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 700),
//   );

//   // 2. Animatsiyalarni init qiling
//   _slideAnimation = Tween<Offset>(
//     begin: const Offset(0, 0.5),
//     end: const Offset(0, 0),
//   ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//   _opacityAnimation = Tween<double>(
//     begin: 0.0,
//     end: 1.0,
//   ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

//   // 3. Elementlarni aralashtiring va animatsiyani boshlang
//   _shuffleItems(); 
// }

// // Qaytadan aralashtirish funksiyasi
// void _shuffleItems() {
//   randomizedItems = List.from(widget.items);
//   randomizedItems.shuffle(Random());

//   // Agar _controller dispose qilinmagan bo'lsa (ya'ni, sahifa yopiq emas)
//   if (mounted) {
//      _controller.reset(); // Qayta boshlash
//      _controller.forward(); // Animatsiyani qayta ishga tushirish
//   }
// }

//   void _initAnimation() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.5),
//       end: const Offset(0, 0),
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//     _opacityAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

//     _controller.forward();
//   }

//   // void _shuffleItems() {
//   //   randomizedItems = List.from(widget.items);
//   //   randomizedItems.shuffle(Random()); // Yangi Random instance
//   //   if (_controller.isAnimating) {
//   //     _controller.reset();
//   //   }
//   //   _controller.forward();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("${widget.tournamentName} - Qura"),
//         backgroundColor: Colors.green,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.shuffle),
//             tooltip: "Qaytadan aralashtirish",
//             onPressed: () {
//               setState(() {
//                 _shuffleItems();
//               });
//             },
//           ),
//         ],
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Juftliklar: ${randomizedItems.length ~/ 2} ta",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const Divider(),
//             Expanded(
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: FadeTransition(
//                   opacity: _opacityAnimation,
//                   child: ListView.builder(
//                     itemCount:
//                         randomizedItems.length ~/ 2, // Faqat juftliklar soni
//                     itemBuilder: (context, index) {
//                       int firstIndex = index * 2;
//                       int secondIndex = index * 2 + 1;

//                       // Juftliklarni olish
//                       PlayerModel firstItem = randomizedItems[firstIndex];
//                       PlayerModel secondItem = randomizedItems[secondIndex];

//                       return _buildItemPair(firstItem, secondItem, index + 1);
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildItemPair(
//       PlayerModel firstItem, PlayerModel secondItem, int pairNumber) {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Juftlik Raqami
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.blueGrey,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Center(
//                   child: Text(
//                 "Juftlik\n#$pairNumber",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                     color: Colors.white, fontWeight: FontWeight.bold),
//               )),
//             ),
//             const SizedBox(width: 15),
//             // Ishtirokchilar
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildPlayerTile(firstItem, "1-o'yinchi"),
//                   const SizedBox(height: 10),
//                   const Center(
//                       child: Text("vs",
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                   const SizedBox(height: 10),
//                   _buildPlayerTile(secondItem, "2-o'yinchi"),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlayerTile(PlayerModel item, String role) {
//     return Row(
//       children: [
//         Container(
//           width: 5,
//           height: 30,
//           decoration: BoxDecoration(
//             color: item.color,
//             borderRadius: BorderRadius.circular(3),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             item.name,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
