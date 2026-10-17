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

    if (mealPlan.isMultiDay) {
      return _MultiDayPlanScreen(mealPlan: mealPlan, bg: bg);
    }

    // Single-day plan
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

class _MultiDayPlanScreen extends StatefulWidget {
  final MealPlanModel mealPlan;
  final Color bg;

  const _MultiDayPlanScreen({required this.mealPlan, required this.bg});

  @override
  State<_MultiDayPlanScreen> createState() => _MultiDayPlanScreenState();
}

class _MultiDayPlanScreenState extends State<_MultiDayPlanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.mealPlan.days.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _planLabel {
    if (widget.mealPlan.durationType == '3day') return '3-Day Meal Plan';
    if (widget.mealPlan.durationType == '7day') return '7-Day Meal Plan';
    return 'Meal Plan';
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.mealPlan.days;

    return Scaffold(
      backgroundColor: widget.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: primaryOrangeDark,
        centerTitle: true,
        title: Text(
          _planLabel,
          style: const TextStyle(
              color: primaryOrangeDark,
              fontWeight: FontWeight.w800,
              fontSize: 14),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: days.length > 4,
          labelColor: primaryOrangeDark,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryOrangeDark,
          tabs: days
              .map((d) => Tab(text: "Day ${d.dayNumber}"))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: days.map((day) {
          // Per-day totals
          final dayCalories =
              day.meals.fold<double>(0, (s, m) => s + m.calories);
          final dayProtein =
              day.meals.fold<double>(0, (s, m) => s + m.protein);
          final dayCarbs = day.meals.fold<double>(0, (s, m) => s + m.carbs);
          final dayFats = day.meals.fold<double>(0, (s, m) => s + m.fats);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              NutritionSummaryCard(
                calories: dayCalories,
                protein: dayProtein,
                carbs: dayCarbs,
                fats: dayFats,
              ),
              const SizedBox(height: 18),
              Text(
                "Day ${day.dayNumber} Meals",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...day.meals.map((meal) => MealCard(meal: meal)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
