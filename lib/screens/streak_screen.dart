import 'package:calorai/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/streak_service.dart';
import '../widgets/streak_card.dart';
import '../widgets/today_progress_card.dart';
import '../models/daily_status_model.dart';

// ── Badge definition ────────────────────────────────────────────────
class _BadgeDef {
  final String name;
  final int days;
  final IconData icon;
  final List<Color> colors; // gradient colors when unlocked

  const _BadgeDef({
    required this.name,
    required this.days,
    required this.icon,
    required this.colors,
  });
}

const _badges = [
  _BadgeDef(
    name: 'Ember',
    days: 3,
    icon: Icons.local_fire_department,
    colors: [Color(0xFFFF6B35), Color(0xFFE53935)],
  ),
  _BadgeDef(
    name: 'Spartan',
    days: 7,
    icon: Icons.shield,
    colors: [Color(0xFF5C6BC0), Color(0xFF7B1FA2)],
  ),
  _BadgeDef(
    name: 'Titan',
    days: 15,
    icon: Icons.fitness_center,
    colors: [Color(0xFF00897B), Color(0xFF43A047)],
  ),
  _BadgeDef(
    name: 'Gladiator',
    days: 30,
    icon: Icons.military_tech,
    colors: [Color(0xFFF9A825), Color(0xFFFF6F00)],
  ),
  _BadgeDef(
    name: 'Olympian',
    days: 90,
    icon: Icons.emoji_events,
    colors: [Color(0xFF7B1FA2), Color(0xFF311B92)],
  ),
  _BadgeDef(
    name: 'Immortal',
    days: 180,
    icon: Icons.auto_awesome,
    colors: [Color(0xFF37474F), Color(0xFF0D0D0D)],
  ),
];

// ── Screen ──────────────────────────────────────────────────────────
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
    return Scaffold(
      backgroundColor: bg,
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
      body: status == null
          ? const Center(
              child: CircularProgressIndicator(color: primaryOrangeLight),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                StreakCard(streak: streak),
                const SizedBox(height: 20),
                TodayProgressCard(status: status!),
                const SizedBox(height: 28),
                _BadgesSection(currentStreak: streak),
              ],
            ),
    );
  }
}

// ── Badges section ──────────────────────────────────────────────────
class _BadgesSection extends StatelessWidget {
  final int currentStreak;
  const _BadgesSection({required this.currentStreak});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Badges",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Earn badges by maintaining your streak",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.82,
          children: _badges
              .map((b) => _BadgeCard(
                    badge: b,
                    currentStreak: currentStreak,
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Single badge card ────────────────────────────────────────────────
class _BadgeCard extends StatelessWidget {
  final _BadgeDef badge;
  final int currentStreak;

  const _BadgeCard({required this.badge, required this.currentStreak});

  @override
  Widget build(BuildContext context) {
    final unlocked = currentStreak >= badge.days;
    final daysNeeded = badge.days - currentStreak;

    return Container(
      decoration: BoxDecoration(
        gradient: unlocked
            ? LinearGradient(
                colors: badge.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFCFD8DC), Color(0xFFB0BEC5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: badge.colors.first.withOpacity(0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: unlocked
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badge.icon,
                    color: unlocked ? Colors.white : Colors.white54,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 10),
                // Badge name
                Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: unlocked ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                // Days label
                Text(
                  unlocked
                      ? '${badge.days}d streak'
                      : '$daysNeeded more days',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: unlocked
                        ? Colors.white.withOpacity(0.8)
                        : Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Lock icon for locked badges
          if (!unlocked)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.white54,
                  size: 11,
                ),
              ),
            ),
          // Checkmark for unlocked badges
          if (unlocked)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
