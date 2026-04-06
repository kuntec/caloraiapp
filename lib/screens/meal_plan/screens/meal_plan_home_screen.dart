import 'package:flutter/material.dart';
import 'nutrition_profile_screen.dart';
import 'meal_plan_history_screen.dart';

class MealPlanHomeScreen extends StatelessWidget {
  final String userId;

  const MealPlanHomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Meal Plan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your smart nutrition coach",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Generate a personalized meal plan based on your height, weight, activity level, diet, and goal.",
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NutritionProfileScreen(
                                userId: userId,
                              ),
                            ),
                          );
                        },
                        child: const Text("Create My Meal Plan"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MealPlanHistoryScreen(userId: userId),
                    ),
                  );
                },
                child: const Text("View Meal Plan History"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
