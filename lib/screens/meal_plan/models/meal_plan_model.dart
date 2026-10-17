class MealItem {
  final String type;
  final String name;
  final List<String> ingredients;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final String servingSize;
  final String notes;

  MealItem({
    required this.type,
    required this.name,
    required this.ingredients,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.servingSize,
    required this.notes,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      type: json["type"] ?? "",
      name: json["name"] ?? "",
      ingredients: List<String>.from(json["ingredients"] ?? []),
      calories: (json["calories"] ?? 0).toDouble(),
      protein: (json["protein"] ?? 0).toDouble(),
      carbs: (json["carbs"] ?? 0).toDouble(),
      fats: (json["fats"] ?? 0).toDouble(),
      servingSize: json["servingSize"] ?? "",
      notes: json["notes"] ?? "",
    );
  }
}

class DayPlan {
  final int dayNumber;
  final List<MealItem> meals;

  DayPlan({
    required this.dayNumber,
    required this.meals,
  });

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      dayNumber: (json["dayNumber"] ?? 0).toInt(),
      meals: (json["meals"] as List<dynamic>? ?? [])
          .map((e) => MealItem.fromJson(e))
          .toList(),
    );
  }
}

class MealPlanModel {
  final String id;
  final String durationType;
  final double targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFats;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final List<MealItem> meals; // 1-day plan
  final List<DayPlan> days;   // multi-day plan

  MealPlanModel({
    required this.id,
    required this.durationType,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFats,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.meals,
    required this.days,
  });

  bool get isMultiDay => days.isNotEmpty;

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json["_id"] ?? "",
      durationType: json["durationType"] ?? "daily",
      targetCalories: (json["targetCalories"] ?? 0).toDouble(),
      targetProtein: (json["targetProtein"] ?? 0).toDouble(),
      targetCarbs: (json["targetCarbs"] ?? 0).toDouble(),
      targetFats: (json["targetFats"] ?? 0).toDouble(),
      totalCalories: (json["totalCalories"] ?? 0).toDouble(),
      totalProtein: (json["totalProtein"] ?? 0).toDouble(),
      totalCarbs: (json["totalCarbs"] ?? 0).toDouble(),
      totalFats: (json["totalFats"] ?? 0).toDouble(),
      meals: (json["meals"] as List<dynamic>? ?? [])
          .map((e) => MealItem.fromJson(e))
          .toList(),
      days: (json["days"] as List<dynamic>? ?? [])
          .map((e) => DayPlan.fromJson(e))
          .toList(),
    );
  }
}
