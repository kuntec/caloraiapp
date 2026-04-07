import 'package:calorai/constants/constants.dart';
import 'package:flutter/material.dart';
import '../models/meal_plan_model.dart';
import '../widgets/meal_card.dart';
import '../widgets/nutrition_summary_card.dart';

class GeneratedMealPlanScreen extends StatelessWidget {
  final MealPlanModel mealPlan;

  const GeneratedMealPlanScreen({super.key, required this.mealPlan});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F7FB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: primaryOrangeDark,
        centerTitle: true,
        title: const Text(
          "Your Meal Plan",
          style: TextStyle(
              color: primaryOrangeDark,
              fontWeight: FontWeight.w800,
              fontSize: 14),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NutritionSummaryCard(
            calories: mealPlan.totalCalories,
            protein: mealPlan.totalProtein,
            carbs: mealPlan.totalCarbs,
            fats: mealPlan.totalFats,
          ),
          const SizedBox(height: 18),
          const Text(
            "Meals",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...mealPlan.meals.map((meal) => MealCard(meal: meal)),
        ],
      ),
    );
  }
}
