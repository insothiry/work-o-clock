import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendanceController extends GetxController {
  var employee = Rxn<Map<String, dynamic>>();
  var attendanceHistory = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var selectedDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchUserAttendance();
  }

  Future<void> fetchUserAttendance({String? from, String? to}) async {
    isLoading(true);
    attendanceHistory.clear();
    String url = 'http://localhost:3000/api/attendances/own-records';

    // Add query parameters for date filtering
    List<String> queryParams = [];
    if (from != null) queryParams.add('from=$from');
    if (to != null) queryParams.add('to=$to');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    SharedPreferences pref = await SharedPreferences.getInstance();
    final String? token = pref.getString('token');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attendanceRecords = data['data'] ?? [];

        if (attendanceRecords.isNotEmpty) {
          final firstRecord = attendanceRecords.first;
          if (firstRecord.containsKey('user') && firstRecord['user'] != null) {
            employee.value = firstRecord['user'];
          }

          attendanceHistory.assignAll(
            attendanceRecords.map<Map<String, dynamic>>((record) {
              return {
                'date': record['clockIn'] != null
                    ? DateTime.parse(record['clockIn'])
                        .toLocal()
                        .toString()
                        .split(' ')[0]
                    : 'N/A',
                'clockIn': record['clockIn'] != null
                    ? DateTime.parse(record['clockIn']).toLocal().toString()
                    : 'N/A',
                'clockOut': record['clockOut'] != null
                    ? DateTime.parse(record['clockOut']).toLocal().toString()
                    : 'N/A',
                'workHours': record['totalWorkHours']?.toString() ?? 'N/A',
                'status': record['statusClockIn'] ?? 'N/A',
                'shift': record['shift'] ?? 'N/A',
                'clockInStatus': record['statusClockIn'] ?? 'N/A',
                'clockOutStatus': record['statusClockOut'] ?? 'N/A',
                'reasonClockIn':
                    record['reasonClockIn'] ?? 'No reason provided',
                'reasonClockOut':
                    record['reasonClockOut'] ?? 'No reason provided',
                'attendanceDate': record['attendanceDate'] ?? 'N/A',
                'location': record['location'] ??
                    {
                      'clockIn': {'latitude': 0.0, 'longitude': 0.0},
                      'clockOut': {'latitude': 0.0, 'longitude': 0.0},
                    }, // Default location
              };
            }).toList(),
          );
        } else {
          attendanceHistory.clear();
        }
      }
    } catch (e) {
      debugPrint("Error fetching attendance: $e");
    } finally {
      isLoading(false);
    }
  }
}
