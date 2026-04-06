import 'dart:convert';
import 'package:calorai/api/api_resources.dart';
import 'package:calorai/api/http_call.dart';
import 'package:calorai/models/DailyMetricsData.dart';
import 'package:calorai/models/FoodData.dart';
import 'package:calorai/models/RecentActivityData.dart';
import 'package:calorai/models/SearchFoodData.dart';
import 'package:calorai/models/UserRegisterData.dart';
import 'package:http/http.dart' as http;

class ApiCall {
  Future<UserRegisterData> register(
      String name,
      String email,
      String password,
      String dob,
      String gender,
      String height,
      String weight,
      String activity,
      String goal) async {
    Uri uri = Uri.parse(APIResource.REGISTER);
    HttpCall call = HttpCall();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final params = <String, dynamic>{
      'email': email,
      'password': password,
      'fullName': name,
      'dateOfBirth': dob,
      'gender': gender,
      'heightCm': height,
      'weightKg': weight,
      'activityLevel': activity,
      'goalType': goal
    };
    print(params);
    http.Response response = await call.post(uri, headers, params);
    print(response.body);
    return UserRegisterData.fromJson(jsonDecode(response.body));
  }

  //
  Future<UserRegisterData> login(String email, String password) async {
    Uri uri = Uri.parse(APIResource.LOGIN);
    HttpCall call = HttpCall();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    print(uri.toString());
    final params = <String, dynamic>{
      'email': email,
      'password': password,
    };
    http.Response response = await call.post(uri, headers, params);
    print(response.body);
    return UserRegisterData.fromJson(jsonDecode(response.body));
  }

  Future<DailyMetricsData> getDailyMetricsToday(String token) async {
    Uri uri = Uri.parse(APIResource.DAILY_METRICS_TODAY);
    HttpCall call = HttpCall();
    try {
      http.Response response = await call.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("DailyMetricsData ${response.body}");
      return DailyMetricsData.fromJson(jsonDecode(response.body));
    } catch (e) {
      print("Error: $e");
      return DailyMetricsData.fromJson({"status": false});
    }
  }

  Future<DailyMetricsData> getDailyMetricsDate(
      String date, String token) async {
    Uri uri = Uri.parse(APIResource.DAILY_METRICS_DATE + date);
    HttpCall call = HttpCall();

    http.Response response = await call.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print("DailyMetricsData By Date ${response.body}");
    return DailyMetricsData.fromJson(jsonDecode(response.body));
  }

  Future<void> updateWaterIntake(
      int currentML, String token, String date) async {
    Uri uri = Uri.parse(APIResource.UPDATE_WATER_INTAKE + date);
    print(uri.toString());
    HttpCall call = HttpCall();

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "waterIntake": {"totalMl": currentML},
        "syncSource": "manual"
      }),
    );
    print("response ${response.body}");
    //return DailyMetricsData.fromJson(jsonDecode(response.body));
  }

  Future<void> addExerciseLog(
    String date,
    String time,
    String type,
    String name,
    String intensity,
    int durationMinutes,
    int caloriesBurned,
    String source,
    String token,
  ) async {
    Uri uri = Uri.parse(APIResource.ADD_EXERCISE_LOG);
    final body = jsonEncode({
      "date": date,
      "time": time,
      "type": type,
      "name": name,
      "intensity": intensity,
      "durationMinutes": durationMinutes,
      "caloriesBurned": caloriesBurned,
      "source": source
    });
    print(body);
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body);

    print("Exercise Log response ${response.body}");
  }

  Future<void> addFoodLog(
    String date,
    String time,
    String mealType,
    String foodId,
    int servings,
    String source,
    String token,
  ) async {
    Uri uri = Uri.parse(APIResource.ADD_FOOD_LOG);
    final body = jsonEncode({
      "date": date,
      "time": time,
      "mealType": mealType,
      "foodId": foodId,
      "servings": servings,
      "source": source
    });
    print(body);
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body);

    print("Food Log response ${response.body}");
  }

  Future<void> deleteFoodLog(String id, String token) async {
    Uri uri = Uri.parse(APIResource.DELETE_FOOD_LOG + id);
    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print("Delete Food Log response ${response.body}");
  }

  Future<void> deleteExerciseLog(String id, String token) async {
    Uri uri = Uri.parse(APIResource.DELETE_EXERCISE_LOG + id);
    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print("Delete Food Log response ${response.body}");
  }

  Future<FoodData> addFood(Food food, String token) async {
    Uri uri = Uri.parse(APIResource.ADD_FOOD);
    print(uri.toString());
    // final body = jsonEncode({
    //   "name": "Boiled Egg",
    //   "brand": "Home",
    //   "description": "Large boiled egg",
    //   "servingSize": 1,
    //   "servingUnit": "piece",
    //   "servingsPerContainer": 1,
    //   "nutrients": {
    //     "calories": 78,
    //     "protein_g": 0,
    //     "carbs_g": 0,
    //     "fats_g": 0,
    //     "saturated_fat_g": 1.6,
    //     "polyunsaturated_fat_g": 0.7,
    //     "monounsaturated_fat_g": 2,
    //     "trans_fat_g": 0,
    //     "cholesterol_mg": 186,
    //     "fiber_g": 0,
    //     "sugar_g": 0.6,
    //     "sodium_mg": 62,
    //     "potassium_mg": 63,
    //     "vitaminA_mcg": 75,
    //     "vitaminC_mg": 0,
    //     "calcium_mg": 28,
    //     "iron_mg": 0.9
    //   },
    //   "source": "user"
    // });
    final body = jsonEncode({
      "name": food.name,
      "brand": food.brand,
      "description": food.description,
      "servingSize": food.servingSize,
      "servingUnit": "serving",
      "servingsPerContainer": food.servingsPerContainer,
      "nutrients": {
        "calories": food.nutrients?.calories,
        "protein_g": food.nutrients?.proteinG,
        "carbs_g": food.nutrients?.carbsG,
        "fats_g": food.nutrients?.fatsG,
        "saturated_fat_g": food.nutrients?.saturatedFatG,
        "polyunsaturated_fat_g": food.nutrients?.polyunsaturatedFatG,
        "monounsaturated_fat_g": food.nutrients?.monounsaturatedFatG,
        "trans_fat_g": food.nutrients?.transFatG,
        "cholesterol_mg": food.nutrients?.cholesterolMg,
        "fiber_g": food.nutrients?.fiberG,
        "sugar_g": food.nutrients?.sugarG,
        "sodium_mg": food.nutrients?.sodiumMg,
        "potassium_mg": food.nutrients?.potassiumMg,
        "vitaminA_mcg": food.nutrients?.vitaminAMcg,
        "vitaminC_mg": food.nutrients?.vitaminCMg,
        "calcium_mg": food.nutrients?.calciumMg,
        "iron_mg": food.nutrients?.ironMg
      },
      "source": food.source
    });
    print(body);
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body);

    print("Exercise Log response ${response.body}");
    return FoodData.fromJson(jsonDecode(response.body));
  }

  Future<SearchFoodData> searchFood(String token, String query) async {
    Uri uri = Uri.parse(APIResource.SEARCH_FOOD + query);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print("Search Food response ${response.body}");
    return SearchFoodData.fromJson(jsonDecode(response.body));
  }

  Future<RecentActivityData> recentActivity(String date, String token) async {
    Uri uri = Uri.parse(APIResource.RECENT_ACTIVITY + date);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print("Recent Activity response ${response.body}");
    return RecentActivityData.fromJson(jsonDecode(response.body));
  }
}
