import 'dart:convert';
import 'package:calorai/api/api_resources.dart';
import 'package:http/http.dart' as http;

class StreakService {
//  static const baseUrl = "http://YOUR_IP:5000/api";
//  static const baseUrl = APIResource.BASE_URL;
  static Future<Map<String, dynamic>> getSummary(String token) async {
    final response = await http.get(
      Uri.parse(APIResource.STREAK_SUMMARY),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }
}
