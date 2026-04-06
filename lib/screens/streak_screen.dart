import 'package:calorai/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/streak_service.dart';
import '../widgets/streak_card.dart';
import '../widgets/today_progress_card.dart';
import '../models/daily_status_model.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  int streak = 0;
  DailyStatus? status;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = await preferences.getString("token");
    final res = await StreakService.getSummary(token!);

    final data = res['data'];

    setState(() {
      streak = data['streaks']['daily_healthy']?['current'] ?? 0;
      status = DailyStatus.fromJson(data['today'] ?? {});
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F7FB);
    const card = Color(0xFFF3F2F8);
    const ink = primaryOrangeDark;
    return Scaffold(
      backgroundColor: bg,
//      appBar: AppBar(title: const Text("CALOR AI")),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Challenges",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: status == null
            ? const Center(
                child: CircularProgressIndicator(
                color: primaryOrangeLight,
              ))
            : Column(
                children: [
                  StreakCard(streak: streak),
                  const SizedBox(height: 20),
                  TodayProgressCard(status: status!),
                ],
              ),
      ),
    );
  }
}
