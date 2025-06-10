// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class AttendanceService {
//   static const String baseUrl = "http://localhost:3000/api/attendances";

//   static Future<String?> _getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }

//   static Future<http.Response?> clockIn(double latitude, double longitude,
//       {String? reason}) async {
//     final token = await _getToken();
//     if (token == null) return null;

//     final response = await http.post(
//       Uri.parse("$baseUrl/clock-in"),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",
//       },
//       body: jsonEncode(
//           {"latitude": latitude, "longitude": longitude, "reason": reason}),
//     );

//     return response;
//   }

//   static Future<http.Response?> clockOut(
//       double latitude, double longitude) async {
//     final token = await _getToken();
//     if (token == null) return null;

//     final response = await http.post(
//       Uri.parse("$baseUrl/clock-out"),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",
//       },
//       body: jsonEncode({"latitude": latitude, "longitude": longitude}),
//     );

//     return response;
//   }
// }
