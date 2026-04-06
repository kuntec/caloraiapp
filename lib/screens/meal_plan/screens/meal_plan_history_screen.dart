import 'package:flutter/material.dart';
import '../models/meal_plan_model.dart';
import '../services/meal_plan_service.dart';
import 'generated_meal_plan_screen.dart';

class MealPlanHistoryScreen extends StatefulWidget {
  final String userId;

  const MealPlanHistoryScreen({super.key, required this.userId});

  @override
  State<MealPlanHistoryScreen> createState() => _MealPlanHistoryScreenState();
}

class _MealPlanHistoryScreenState extends State<MealPlanHistoryScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Plan History"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
              ? const Center(child: Text("No meal plans found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return Card(
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
                ),
    );
  }
}
