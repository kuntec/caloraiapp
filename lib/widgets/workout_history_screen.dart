// //import 'package:calorai/models/WorkoutItem.dart';
// import 'package:flutter/material.dart';
//
// class WorkoutHistoryScreen extends StatefulWidget {
//   const WorkoutHistoryScreen({super.key});
//
//   @override
//   State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
// }
//
// class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
//   final List<WorkoutItem> workouts = [
//     WorkoutItem(
//       title: "Manual",
//       calories: 800,
//       duration: null,
//       time: "06:21 PM",
//       icon: Icons.local_fire_department,
//       isManual: true,
//     ),
//     WorkoutItem(
//       title: "Weight Lifting",
//       calories: 72,
//       duration: 30,
//       time: "06:21 PM",
//       icon: Icons.fitness_center,
//     ),
//     WorkoutItem(
//       title: "Run",
//       calories: 126,
//       duration: 30,
//       time: "06:21 PM",
//       icon: Icons.directions_run,
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7FB),
//       body: SafeArea(
//         child: ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: workouts.length,
//           itemBuilder: (context, index) {
//             final item = workouts[index];
//
//             return Dismissible(
//               key: ValueKey(item),
//               direction: DismissDirection.endToStart,
//               background: _deleteBackground(),
//               onDismissed: (_) {
//                 setState(() => workouts.removeAt(index));
//               },
//               child: _WorkoutCard(item: item),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _deleteBackground() {
//     return Container(
//       alignment: Alignment.centerRight,
//       padding: const EdgeInsets.only(right: 30),
//       decoration: BoxDecoration(
//         color: const Color(0xFF0E0E10),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: const [
//           Icon(Icons.delete_outline, color: Colors.white, size: 26),
//           SizedBox(height: 6),
//           Text(
//             "Delete",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//           )
//         ],
//       ),
//     );
//   }
// }
//
// class _WorkoutCard extends StatelessWidget {
//   final WorkoutItem item;
//
//   const _WorkoutCard({required this.item});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF3F2F8),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           // Left Icon
//           CircleAvatar(
//             radius: 28,
//             backgroundColor: Colors.white,
//             child: Icon(item.icon, size: 26, color: Colors.black),
//           ),
//
//           const SizedBox(width: 14),
//
//           // Middle Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     const Icon(Icons.local_fire_department,
//                         size: 16, color: Colors.black),
//                     const SizedBox(width: 6),
//                     Text(
//                       "${item.calories} calories",
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     const Icon(Icons.wb_sunny_outlined, size: 16),
//                     const SizedBox(width: 4),
//                     const Text("-"),
//                     const SizedBox(width: 16),
//                     const Icon(Icons.timer_outlined, size: 16),
//                     const SizedBox(width: 4),
//                     Text(item.duration != null ? "${item.duration} min" : "-"),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // Time badge
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Text(
//               item.time,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
