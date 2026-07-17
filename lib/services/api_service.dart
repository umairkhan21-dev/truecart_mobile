import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://truecart-production.up.railway.app";

  static Future<Map<String, dynamic>> analyzeProduct({
    required Map<String, dynamic> productData,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/analyze?source=app"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode(productData),
    );

    debugPrint("STATUS CODE:");
    debugPrint(response.statusCode.toString());

    debugPrint("RAW RESPONSE:");
    debugPrint(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        "Backend returned ${response.statusCode}: ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body);

    debugPrint("DECODED TYPE:");
    debugPrint(decoded.runtimeType.toString());

    if (decoded is Map<String, dynamic>) {
      debugPrint("RESULT TYPE:");
      debugPrint(decoded["result"].runtimeType.toString());

      return decoded;
    }

    return {"response": decoded.toString()};
  }

  // NEW FUNCTION
  // static Future<Map<String, dynamic>> analyzeUrl({required String url}) async {
  //   final response = await http.post(
  //     Uri.parse("$baseUrl/analyze-url"),

  //     headers: {"Content-Type": "application/json"},

  //     body: jsonEncode({"url": url}),
  //   );

  //   debugPrint("STATUS CODE:");
  //   debugPrint(response.statusCode.toString());

  //   debugPrint("RAW RESPONSE:");
  //   debugPrint(response.body);

  //   if (response.statusCode != 200) {
  //     throw Exception("Backend returned ${response.statusCode}");
  //   }

  //   final decoded = jsonDecode(response.body);

  //   return decoded;
  // }

  static Future<Map<String, dynamic>> analyzeUrl({required String url}) async {
    debugPrint("URL RECEIVED:");
    debugPrint(url);

    return {
      "success": true,

      "result": {
        "summary": "Good product",

        "pros": ["Good battery", "Nice build quality"],

        "cons": ["Expensive"],
      },

      "productData": {
        "title": "Test Product",
        "price": "₹999",
        "rating": "4.5",
      },
    };
  }
}
