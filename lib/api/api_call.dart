import 'dart:convert';
import 'package:intl/intl.dart';
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
      String goal,
      {String? firebaseUid}) async {
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
      'goalType': goal,
      if (firebaseUid != null && firebaseUid.isNotEmpty)
        'firebaseUid': firebaseUid,
    };
    // print(params);
    http.Response response = await call.post(uri, headers, params);
    // print(response.body);
    return UserRegisterData.fromJson(jsonDecode(response.body));
  }

  /// Check if a social-auth user already exists on the backend.
  /// Returns their token + profile if found, or exists=false if new user.
  Future<UserRegisterData> socialLogin(String uid, String email) async {
    Uri uri = Uri.parse(APIResource.SOCIAL_LOGIN);
    HttpCall call = HttpCall();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final params = <String, dynamic>{'uid': uid, 'email': email};
    http.Response response = await call.post(uri, headers, params);
    // print('socialLogin response: ${response.body}');
    return UserRegisterData.fromJson(jsonDecode(response.body));
  }

  //
  Future<UserRegisterData> getMe(String token) async {
    Uri uri = Uri.parse(APIResource.AUTH_ME);
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    return UserRegisterData.fromJson(jsonDecode(response.body));
  }

  Future<UserRegisterData> login(String email, String password) async {
    Uri uri = Uri.parse(APIResource.LOGIN);
    HttpCall call = HttpCall();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    // print(uri.toString());
    final params = <String, dynamic>{
      'email': email,
      'password': password,
    };
    http.Response response = await call.post(uri, headers, params);
    // print(response.body);
    return UserRegisterData.fromJson(jsonDecode(response.body));
  }

  Future<DailyMetricsData> getDailyMetricsToday(String token) async {
    // Pass the user's local date explicitly — /today uses the server's UTC
    // date which mismatches when local time is past midnight but UTC is not.
    final localDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Uri uri = Uri.parse(APIResource.DAILY_METRICS_DATE + localDate);
    HttpCall call = HttpCall();
    try {
      http.Response response = await call.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return DailyMetricsData.fromJson(jsonDecode(response.body));
    } catch (e) {
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
    // print("DailyMetricsData By Date ${response.body}");
    return DailyMetricsData.fromJson(jsonDecode(response.body));
  }

  Future<void> updateWaterIntake(
      int currentML, String token, String date) async {
    Uri uri = Uri.parse(APIResource.UPDATE_WATER_INTAKE + date);
    // print(uri.toString());
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
    // print("response ${response.body}");
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
    // print(uri);
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
    // print(body);
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body);
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Exercise log failed: ${response.statusCode}');
    }
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
    // print(body);
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body);

    // print("Food Log response ${response.body}");
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
    // print("Delete Food Log response ${response.body}");
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
    // print("Delete Food Log response ${response.body}");
  }

  Future<FoodData> addFood(Food food, String token) async {
    Uri uri = Uri.parse(APIResource.ADD_FOOD);
    // print(uri.toString());
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
    // print(body);
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body);

    // print("Exercise Log response ${response.body}");
    return FoodData.fromJson(jsonDecode(response.body));
  }

  Future<SearchFoodData> searchFood(String token, String query,
      {int page = 1}) async {
    Uri uri = Uri.parse(APIResource.SEARCH_FOOD +
        Uri.encodeQueryComponent(query) +
        '&page=${page}');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}',
      },
    );
    return SearchFoodData.fromJson(jsonDecode(response.body));
  }

  /// Search only this user's personal foods (source=user, createdBy=me).
  Future<SearchFoodData> searchMyFood(String token, String query,
      {int page = 1}) async {
    Uri uri = Uri.parse(APIResource.SEARCH_MY_FOOD +
        Uri.encodeQueryComponent(query) +
        '&page=${page}');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}',
      },
    );
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
    // print("Recent Activity response ${response.body}");
    return RecentActivityData.fromJson(jsonDecode(response.body));
  }

  Future<UserRegisterData> updateProfile({
    required String token,
    String? fullName,
    String? heightCm,
    String? weightKg,
    String? activityLevel,
    String? goalType,
  }) async {
    Uri uri = Uri.parse(APIResource.UPDATE_PROFILE);
    final body = <String, dynamic>{};
    if (fullName != null && fullName.isNotEmpty) body['fullName'] = fullName;
    if (heightCm != null) body['heightCm'] = int.tryParse(heightCm) ?? 0;
    if (weightKg != null) body['weightKg'] = int.tryParse(weightKg) ?? 0;
    if (activityLevel != null) body['activityLevel'] = activityLevel;
    if (goalType != null) body['goalType'] = goalType;

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    // print("updateProfile ${response.body}");
    return UserRegisterData.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteAccount(String token) async {
    Uri uri = Uri.parse(APIResource.DELETE_ACCOUNT);
    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // print("Delete Account response ${response.statusCode} ${response.body}");
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete account. Please try again.');
    }
  }

  /// Fetch daily metrics for a date range, returns list of raw maps.
  Future<List<Map<String, dynamic>>> getWeeklyMetrics(
      String startDate, String endDate, String token) async {
    final uri = Uri.parse(
        '${APIResource.DAILY_METRICS_RANGE}?start=$startDate&end=$endDate');
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = body['metrics'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }
}
