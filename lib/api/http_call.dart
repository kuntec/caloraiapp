import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class HttpCall {
  final Duration _timeoutDuration = const Duration(seconds: 15);

  /// ✅ Check internet connection before every API call
  Future<bool> _hasInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// ✅ Generic GET request
  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) async {
    if (!await _hasInternet()) {
      throw Exception("No Internet Connection");
    }

    try {
      final response =
          await http.get(uri, headers: headers).timeout(_timeoutDuration);
      _logResponse("GET", uri, response);
      return _handleResponse(response);
    } on SocketException {
      throw Exception("Unable to reach server");
    } on http.ClientException {
      throw Exception("Invalid request");
    } on TimeoutException {
      throw Exception("Request timed out");
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ Generic POST request
  Future<http.Response> post(
      Uri uri, Map<String, String> headers, Map<String, dynamic> params) async {
    if (!await _hasInternet()) {
      throw Exception("No Internet Connection");
    }
    try {
      final response = await http
          .post(uri, headers: headers, body: jsonEncode(params))
          .timeout(_timeoutDuration);
      _logResponse("POST", uri, response);
      return _handleResponse(response);
    } on SocketException {
      throw Exception("Unable to reach server");
    } on http.ClientException {
      throw Exception("Invalid request");
    } on TimeoutException {
      throw Exception("Request timed out");
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ DELETE request
  Future<http.Response> delete(Uri uri, {Map<String, String>? headers}) async {
    if (!await _hasInternet()) {
      throw Exception("No Internet Connection");
    }

    try {
      final response =
          await http.delete(uri, headers: headers).timeout(_timeoutDuration);
      _logResponse("DELETE", uri, response);
      return _handleResponse(response);
    } on SocketException {
      throw Exception("Unable to reach server");
    } on http.ClientException {
      throw Exception("Invalid request");
    } on TimeoutException {
      throw Exception("Request timed out");
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ Log API responses (for debugging)
  void _logResponse(String method, Uri uri, http.Response response) {
    print('[$method] ${uri.toString()} → ${response.statusCode}');
    if (response.statusCode >= 400) {
      print('Response body: ${response.body}');
    }
  }

  /// ✅ Handle response status codes
  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw Exception(
          "HTTP Error: ${response.statusCode} → ${response.reasonPhrase}");
    }
  }
}
