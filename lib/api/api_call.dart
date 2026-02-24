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

    http.Response response = await call.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print("DailyMetricsData ${response.body}");
    return DailyMetricsData.fromJson(jsonDecode(response.body));
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

  Future<void> updateWaterIntake(int currentML, String token) async {
    Uri uri = Uri.parse(APIResource.UPDATE_WATER_INTAKE);
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

  Future<SearchFoodData> searchFood(String token) async {
    Uri uri = Uri.parse(APIResource.SEARCH_FOOD);
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

  //
  // Future<GetUserData> myAccount(String phone) async {
  //   Uri uri = Uri.parse(APIResource.MY_ACCOUNT);
  //   print(phone);
  //   print(uri.toString());
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //
  //   params['phone'] = phone;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return GetUserData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<VehicleData> addVehicle(String userId, String emirate, String type,
  //     String make, String model, String plateNo, String color) async {
  //   Uri uri = Uri.parse(APIResource.ADD_VEHICLE);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //
  //   params['user_id'] = userId;
  //   params['type'] = type;
  //   params['make'] = make;
  //   params['model'] = model;
  //   params['emirate'] = emirate;
  //   params['plate_no'] = plateNo;
  //   params['color'] = color;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return VehicleData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<VehicleData> myVehicles(String userId) async {
  //   print(userId);
  //   Uri uri = Uri.parse(APIResource.MY_VEHICLES);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //
  //   params['user_id'] = userId;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return VehicleData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<VehicleData> deleteVehicle(String id) async {
  //   Uri uri = Uri.parse(APIResource.DELETE_VEHICLE);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //
  //   params['id'] = id;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return VehicleData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<AddressData> addAddress(String userId, String address, String label,
  //     String lat, String lang) async {
  //   Uri uri = Uri.parse(APIResource.ADD_ADDRESS);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //
  //   params['user_id'] = userId;
  //   params['address'] = address;
  //   params['label'] = label;
  //   params['lat'] = lat;
  //   params['lang'] = lang;
  //
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return AddressData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<AddressData> myAddresses(String userId) async {
  //   print(userId);
  //   Uri uri = Uri.parse(APIResource.MY_ADDRESSES);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //
  //   params['user_id'] = userId;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return AddressData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<AddressData> deleteAddress(String id) async {
  //   Uri uri = Uri.parse(APIResource.DELETE_ADDRESS);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //
  //   params['id'] = id;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return AddressData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<GetServiceData> allServices(String userId) async {
  //   Uri uri = Uri.parse(APIResource.ALL_SERVICES);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //
  //   params['user_id'] = userId;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return GetServiceData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<GetServiceData> getAllServices() async {
  //   Uri uri = Uri.parse(APIResource.GET_ALL_SERVICES);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return GetServiceData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<AddressData> setDefaultAddress(String id) async {
  //   Uri uri = Uri.parse(APIResource.SET_DEFAULT_ADDRESS);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //
  //   params['id'] = id;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return AddressData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<VehicleData> setDefaultVehicle(String id) async {
  //   Uri uri = Uri.parse(APIResource.SET_DEFAULT_VEHICLE);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //
  //   params['id'] = id;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return VehicleData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<MyBookingData> addBooking(Bookings booking) async {
  //   Uri uri = Uri.parse(APIResource.ADD_BOOKING);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //
  //   params['user_id'] = booking.userId;
  //   params['vehicle_id'] = booking.vehicleId;
  //   params['address_id'] = booking.addressId;
  //   params['service_id'] = booking.serviceId;
  //   params['booking_date'] = booking.bookingDate;
  //   params['booking_time'] = booking.bookingTime;
  //   params['status'] = booking.status;
  //   params['notes'] = booking.notes;
  //   params['amount'] = booking.amount;
  //   params['payment_type'] = booking.paymentType;
  //   params['payment_status'] = booking.paymentStatus;
  //
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return MyBookingData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<MyBookingData> myBookings(String userid) async {
  //   Uri uri = Uri.parse(APIResource.MY_BOOKINGS);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //   params['user_id'] = userid;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return MyBookingData.fromJson(jsonDecode(response.body));
  // }
  //
  // //Washer API
  // Future<WasherData> loginWasher(String email, String password) async {
  //   Uri uri = Uri.parse(APIResource.LOGIN_WASHER);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //   params['email'] = email;
  //   params['password'] = password;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return WasherData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<WasherDashboardData> washerDashboard(String washerId) async {
  //   Uri uri = Uri.parse(APIResource.WASHER_DASHBOARD);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //   params['id'] = washerId;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return WasherDashboardData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<WasherDashboardData> updateBookingStatus(
  //     String bookingId, String status) async {
  //   Uri uri = Uri.parse(APIResource.UPDATE_BOOKING);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //   params['booking_id'] = bookingId;
  //   params['status'] = status;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return WasherDashboardData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<MarketerDashboardData> marketerDashboard(String userId) async {
  //   Uri uri = Uri.parse(APIResource.MARKETER_DASHBOARD);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //   params['user_id'] = userId;
  //   print(userId);
  //   try {
  //     http.Response response = await call.post(uri, header, params);
  //     print(response.body);
  //     return MarketerDashboardData.fromJson(jsonDecode(response.body));
  //   } catch (e) {
  //     print(e);
  //     return MarketerDashboardData.fromJson(jsonDecode(e.toString()));
  //   }
  // }
  //
  // Future<GetUserData> addMarketerUser(
  //     String userId, String name, String email, String phone) async {
  //   Uri uri = Uri.parse(APIResource.MARKETER_ADD_USER);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //   params['user_id'] = userId;
  //   params['name'] = name;
  //   params['email'] = email;
  //   params['phone'] = phone;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return GetUserData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<MarketerUsersData> getMarketerUsers(String userId) async {
  //   Uri uri = Uri.parse(APIResource.MARKETER_USERS);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //   params['user_id'] = userId;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return MarketerUsersData.fromJson(jsonDecode(response.body));
  // }
  //
  // Future<NotificationData> getNotifications(String userid) async {
  //   Uri uri = Uri.parse(APIResource.GET_NOTIFICATIONS);
  //   HttpCall call = HttpCall();
  //   var header = Map<String, String>();
  //   var params = Map<String, dynamic>();
  //   params['user_id'] = userid;
  //   http.Response response = await call.post(uri, header, params);
  //   print(response.body);
  //   return NotificationData.fromJson(jsonDecode(response.body));
  // }
}
