import 'package:calorai/constants/constants.dart';
import 'package:calorai/screens/meal_plan/models/meal_plan_model.dart';
import 'package:calorai/screens/meal_plan/screens/generated_meal_plan_screen.dart';
import 'package:calorai/screens/meal_plan/services/meal_plan_service.dart';
import 'package:flutter/material.dart';
import 'nutrition_profile_screen.dart';
import 'meal_plan_history_screen.dart';

class MealPlanHomeScreen extends StatefulWidget {
  final String userId;
  const MealPlanHomeScreen({super.key, required this.userId});

  @override
  State<MealPlanHomeScreen> createState() => _MealPlanHomeScreenState();
}

class _MealPlanHomeScreenState extends State<MealPlanHomeScreen> {
  final service = MealPlanService();
  bool isLoading = true;
  List<MealPlanModel> plans = [];

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    try {
      final result = await service.getMealPlans(widget.userId);
      setState(() {
        plans = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F7FB);
    const card = Color(0xFFF3F2F8);
    const ink = primaryOrangeDark;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: ink,
        centerTitle: true,
        title: const Text(
          "AI MEAL PLAN",
          style: TextStyle(
              color: primaryOrangeDark,
              fontWeight: FontWeight.w800,
              fontSize: 14),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    primaryOrangeLight,
                    Color(0xFFFF5C00),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your smart nutrition coach",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Generate a personalized meal plan based on your height, weight, activity level, diet, and goal.",
                      style: TextStyle(
                        color: Colors.white,
                      ),
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
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Create My Meal Plan",
                          style: TextStyle(
                              color: primaryOrangeDark,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Meal Plan History",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // SizedBox(
            //   width: double.infinity,
            //   child: OutlinedButton(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (_) =>
            //               MealPlanHistoryScreen(userId: widget.userId),
            //         ),
            //       );
            //     },
            //     child: const Text("View Meal Plan History"),
            //   ),
            // ),
            Expanded(
              child: mealHistory(),
            ),
          ],
        ),
      ),
    );
  }

  Widget mealHistory() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : plans.isEmpty
            ? const Center(child: Text("No meal plans found"))
            : ListView.builder(
                //padding: const EdgeInsets.all(10),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          primaryOrangeLight,
                          Color(0xFFFF5C00),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text("Meal Plan ${index + 1}"),
                      subtitle: Text(
                        "${plan.totalCalories.toStringAsFixed(0)} kcal • ${plan.meals.length} meals",
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GeneratedMealPlanScreen(
                              mealPlan: plan,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
  }
}
