import 'package:calorai/api/api_call.dart';
import 'package:calorai/components/CalorieRing.dart';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/screens/dashboard_screen.dart';
import 'package:calorai/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddBurnedCaloriesScreen extends StatefulWidget {
  String type;
  String name;
  String intensity;
  int durationMinutes;
  int caloriesBurned;

  AddBurnedCaloriesScreen(
      {super.key,
      required this.type,
      required this.name,
      required this.intensity,
      required this.durationMinutes,
      required this.caloriesBurned});

  @override
  State<AddBurnedCaloriesScreen> createState() =>
      _AddBurnedCaloriesScreenState();
}

class _AddBurnedCaloriesScreenState extends State<AddBurnedCaloriesScreen> {
  int calories = 72;

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    calories = widget.caloriesBurned;
  }

  void _editCalories() async {
    final controller = TextEditingController(text: calories.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Calories"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                int.tryParse(controller.text) ?? calories,
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => calories = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF0E0E10);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: primaryOrangeLight,
              ))
            : Column(
                children: [
                  // App bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _CircleButton(
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Text(
                          "Add Burned Calories",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Circular indicator
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CustomPaint(
                      painter: CalorieRingPainter(progress: 0.75),
                      child: const Center(
                        child: Icon(
                          Icons.local_fire_department,
                          size: 30,
                          color: ink,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Text
                  const Text(
                    "Your workout burned",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Calories + edit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$calories cals",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _editCalories,
                        child: const Icon(
                          Icons.edit,
                          size: 22,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bottom button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          //debugPrint("Logged $calories calories");
                          addExerciseLog();
                        },
                        child: const Text(
                          "Log",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void addExerciseLog() async {
    setState(() {
      isLoading = true;
    });
    ApiCall call = new ApiCall();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString("token") ?? "";
    DateTime now = DateTime.now();

// Format date → "2026-02-18"
    String date = DateFormat('yyyy-MM-dd').format(now);
// Format time → "02:00 PM"
    String time = DateFormat('hh:mm a').format(now);
    String type = widget.type;
    String name = widget.name;
    String intensity = widget.intensity;
    int durationMinutes = widget.durationMinutes;
    int caloriesBurned = calories;
    String source = "manual";
    call.addExerciseLog(date, time, type, name, intensity, durationMinutes,
        caloriesBurned, source, token);

    setState(() {
      isLoading = false;
    });
    MyUtility.removePage(context, MainNavigationScreen());
  }
}

/// 🔥 Circular ring painter
// class _CalorieRingPainter extends CustomPainter {
//   final double progress; // 0.0 - 1.0
//
//   _CalorieRingPainter({required this.progress});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     const stroke = 10.0;
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = (size.width - stroke) / 2;
//
//     final bgPaint = Paint()
//       ..color = const Color(0xFFEAEAEA)
//       ..strokeWidth = stroke
//       ..style = PaintingStyle.stroke;
//
//     final fgPaint = Paint()
//       ..shader = const LinearGradient(
//         colors: [Color(0xFF0E0E10), Color(0xFF2C2C30)],
//       ).createShader(Rect.fromCircle(center: center, radius: radius))
//       ..strokeWidth = stroke
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.stroke;
//
//     canvas.drawCircle(center, radius, bgPaint);
//
//     final sweepAngle = 2 * pi * progress;
//     canvas.drawArc(
//       Rect.fromCircle(center: center, radius: radius),
//       -pi / 2,
//       sweepAngle,
//       false,
//       fgPaint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

/// 🔘 Circular back button
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFF2F2F6),
        ),
        child: Icon(icon, color: const Color(0xFF0E0E10)),
      ),
    );
  }
}
