import 'dart:convert';
import 'package:calorai/api/api_resources.dart';
import 'package:http/http.dart' as http;
import '../models/meal_plan_model.dart';
import '../models/nutrition_profile_model.dart';

class MealPlanService {
  Future<void> saveProfile(NutritionProfile profile) async {
    // print(APIResource.ADD_MEAL_PROFILE);
    final response = await http.post(
      Uri.parse(APIResource.ADD_MEAL_PROFILE),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(profile.toJson()),
    );
    // print(jsonEncode(profile.toJson()));
    // print(response.body);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["success"] != true) {
      // print("FAILED TO SAVE PROFILE");
      throw Exception(data["message"] ?? "Failed to save profile");
    }
  }

  Future<MealPlanModel> generateMealPlan(String userId,
      {int numberOfDays = 1}) async {
    String durationType;
    if (numberOfDays == 3) {
      durationType = "3day";
    } else if (numberOfDays == 7) {
      durationType = "7day";
    } else {
      durationType = "daily";
    }

    final response = await http.post(
      Uri.parse(APIResource.GENERATE_MEAL_PLAN),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "durationType": durationType,
        "numberOfDays": numberOfDays,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["success"] != true) {
      throw Exception(data["message"] ?? "Failed to generate meal plan");
    }

    return MealPlanModel.fromJson(data["data"]["mealPlan"]);
  }

  Future<List<MealPlanModel>> getMealPlans(String userId) async {
    // print(APIResource.ALL_MEAL_PLANS + "/$userId");
    final response = await http.get(
      Uri.parse(APIResource.ALL_MEAL_PLANS + "/$userId"),
      headers: {"Content-Type": "application/json"},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["success"] != true) {
      throw Exception(data["message"] ?? "Failed to fetch meal plans");
    }

    return (data["data"] as List<dynamic>)
        .map((e) => MealPlanModel.fromJson(e))
        .toList();
  }
}
