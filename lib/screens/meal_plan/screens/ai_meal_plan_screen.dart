import 'package:flutter/material.dart';

class AiMealPlanScreen extends StatelessWidget {
  final VoidCallback onGenerateTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onEditProfileTap;

  const AiMealPlanScreen({
    super.key,
    required this.onGenerateTap,
    required this.onHistoryTap,
    required this.onEditProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF4EEF7);
    const cardColor = Color(0xFFF1ECF3);
    const textDark = Color(0xFF201C24);
    const textMuted = Color(0xFF6E6680);
    const primaryPurple = Color(0xFF7B67B2);
    const orange1 = Color(0xFFFFB000);
    const orange2 = Color(0xFFFF6A00);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textDark),
        title: const Text(
          "AI MEAL PLAN",
          style: TextStyle(
            color: textDark,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        children: [
          _aiCoachCard(
            cardColor: cardColor,
            textDark: textDark,
            textMuted: textMuted,
          ),
          const SizedBox(height: 16),
          _profileCard(
            cardColor: Colors.white,
            textDark: textDark,
            textMuted: textMuted,
            primaryPurple: primaryPurple,
            onEditTap: onEditProfileTap,
          ),
          const SizedBox(height: 16),
          _whatYouGetCard(
            cardColor: Colors.white,
            textDark: textDark,
            textMuted: textMuted,
            primaryPurple: primaryPurple,
          ),
          const SizedBox(height: 18),
          Container(
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [orange1, orange2],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onGenerateTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "GENERATE TODAY’S PLAN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text(
                "HISTORY",
                style: TextStyle(
                  color: textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onHistoryTap,
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _historyCard(
            title: "Yesterday’s Plan",
            subtitle: "1800 kcal • 4 meals",
            date: "Apr 05",
            textDark: textDark,
            textMuted: textMuted,
            primaryPurple: primaryPurple,
          ),
          const SizedBox(height: 12),
          _historyCard(
            title: "High Protein Plan",
            subtitle: "2000 kcal • 5 meals",
            date: "Apr 04",
            textDark: textDark,
            textMuted: textMuted,
            primaryPurple: primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _aiCoachCard({
    required Color cardColor,
    required Color textDark,
    required Color textMuted,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "YOUR AI NUTRITION COACH",
            style: TextStyle(
              color: Color(0xFF201C24),
              fontSize: 23,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          SizedBox(height: 14),
          Text(
            "Get a personalized meal plan based on your body, goals, and lifestyle.",
            style: TextStyle(
              color: Color(0xFF6E6680),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard({
    required Color cardColor,
    required Color textDark,
    required Color textMuted,
    required Color primaryPurple,
    required VoidCallback onEditTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "YOUR PROFILE",
                style: TextStyle(
                  color: textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEditTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 15, color: primaryPurple),
                      SizedBox(width: 6),
                      Text(
                        "Edit",
                        style: TextStyle(
                          color: primaryPurple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _ProfileInfo(label: "Height", value: "175 cm")),
              Expanded(child: _ProfileInfo(label: "Weight", value: "75 kg")),
            ],
          ),
          SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: _ProfileInfo(label: "Goal", value: "Fat Loss")),
              Expanded(
                  child: _ProfileInfo(label: "Diet", value: "High Protein")),
            ],
          ),
          SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                  child: _ProfileInfo(label: "Activity", value: "Moderate")),
              Expanded(
                  child: _ProfileInfo(label: "Meals/Day", value: "4 Meals")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _whatYouGetCard({
    required Color cardColor,
    required Color textDark,
    required Color textMuted,
    required Color primaryPurple,
  }) {
    final items = [
      "Breakfast, lunch, dinner, and snacks",
      "Calories aligned to your goal",
      "Protein, carbs, and fats breakdown",
      "Personalized food suggestions",
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "WHAT YOU’LL GET",
            style: TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(
                      color: primaryPurple.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: primaryPurple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard({
    required String title,
    required String subtitle,
    required String date,
    required Color textDark,
    required Color textMuted,
    required Color primaryPurple,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9E2EE)),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: primaryPurple,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: TextStyle(
              color: textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF6E6680),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF201C24),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
