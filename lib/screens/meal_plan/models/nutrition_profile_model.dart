class NutritionProfile {
  final String userId;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final double? targetWeightKg;
  final String activityLevel;
  final String goal;
  final String dietType;
  final bool halalRequired;
  final int mealsPerDay;
  final List<String> cuisinePreference;
  final List<String> allergies;
  final List<String> excludedFoods;
  final String notes;

  NutritionProfile({
    required this.userId,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    this.targetWeightKg,
    required this.activityLevel,
    required this.goal,
    required this.dietType,
    required this.halalRequired,
    required this.mealsPerDay,
    required this.cuisinePreference,
    required this.allergies,
    required this.excludedFoods,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "age": age,
      "gender": gender,
      "heightCm": heightCm,
      "weightKg": weightKg,
      "targetWeightKg": targetWeightKg,
      "activityLevel": activityLevel,
      "goal": goal,
      "dietType": dietType,
      "halalRequired": halalRequired,
      "mealsPerDay": mealsPerDay,
      "cuisinePreference": cuisinePreference,
      "allergies": allergies,
      "excludedFoods": excludedFoods,
      "notes": notes,
    };
  }

  factory NutritionProfile.fromJson(Map<String, dynamic> json) {
    return NutritionProfile(
      userId: json["userId"] ?? "",
      age: json["age"] ?? 0,
      gender: json["gender"] ?? "",
      heightCm: (json["heightCm"] ?? 0).toDouble(),
      weightKg: (json["weightKg"] ?? 0).toDouble(),
      targetWeightKg: json["targetWeightKg"] != null
          ? (json["targetWeightKg"]).toDouble()
          : null,
      activityLevel: json["activityLevel"] ?? "",
      goal: json["goal"] ?? "",
      dietType: json["dietType"] ?? "",
      halalRequired: json["halalRequired"] ?? false,
      mealsPerDay: json["mealsPerDay"] ?? 4,
      cuisinePreference: List<String>.from(json["cuisinePreference"] ?? []),
      allergies: List<String>.from(json["allergies"] ?? []),
      excludedFoods: List<String>.from(json["excludedFoods"] ?? []),
      notes: json["notes"] ?? "",
    );
  }
}
