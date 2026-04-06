import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/food_scan_model.dart';

class FoodScanService {
  static const String baseUrl =
      "https://calroai-backend.vercel.app/api/food-scan";
  // Android emulator:
  // static const String baseUrl = "http://10.0.2.2:5000/api/food-scan";

  Future<FoodScanModel> analyzeFood({
    required String userId,
    required File imageFile,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/analyze"),
    );

    request.fields["userId"] = userId;
    request.files.add(
      await http.MultipartFile.fromPath("image", imageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["success"] != true) {
      throw Exception(data["message"] ?? "Failed to analyze food image");
    }

    return FoodScanModel.fromJson(data["data"]);
  }

  Future<List<FoodScanModel>> getHistory(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/history/$userId"),
      headers: {"Content-Type": "application/json"},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["success"] != true) {
      throw Exception(data["message"] ?? "Failed to load food scan history");
    }

    return (data["data"] as List<dynamic>)
        .map((e) => FoodScanModel.fromJson(e))
        .toList();
  }

  Future<FoodScanModel> getSingleScan({
    required String scanId,
    required String userId,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/$scanId?userId=$userId"),
      headers: {"Content-Type": "application/json"},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["success"] != true) {
      throw Exception(data["message"] ?? "Failed to fetch scan");
    }

    return FoodScanModel.fromJson(data["data"]);
  }

  Future<FoodScanModel> confirmScan({
    required String scanId,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$scanId/confirm"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["success"] != true) {
      throw Exception(data["message"] ?? "Failed to confirm scan");
    }

    return FoodScanModel.fromJson(data["data"]);
  }

  Future<void> addToLog({
    required String scanId,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$scanId/add-to-log"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["success"] != true) {
      throw Exception(data["message"] ?? "Failed to add to food log");
    }
  }

  Future<void> deleteScan({
    required String scanId,
    required String userId,
  }) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/$scanId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["success"] != true) {
      throw Exception(data["message"] ?? "Failed to delete scan");
    }
  }
}
