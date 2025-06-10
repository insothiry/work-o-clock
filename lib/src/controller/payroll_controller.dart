import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PayrollController extends GetxController {
  RxDouble totalHours = 0.0.obs;
  RxDouble hourlyRate = 0.0.obs;
  RxDouble totalSalary = 0.0.obs;
  RxDouble monthlyRate = 0.0.obs;
  Rx<DateTime> selectedMonth = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchSalaryForSelectedMonth();
    fetchUserRates();
  }

  Future<void> selectMonth(BuildContext context) async {
    final picked = await showMonthPicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime(2050));

    if (picked != null) {
      selectedMonth.value = picked;
      fetchSalaryForSelectedMonth();
    }
  }

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> fetchSalaryForSelectedMonth() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final pref = await SharedPreferences.getInstance();
      final token = pref.getString('token');
      final month =
          '${selectedMonth.value.year}-${selectedMonth.value.month.toString().padLeft(2, '0')}';

      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/api/payroll/calculate-salary?month=$month'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (data is List && data.isNotEmpty) {
          final info = data[0];

          totalHours.value = (info['totalHours'] ?? 0).toDouble();
          hourlyRate.value = (info['hourlyRate'] ?? 0).toDouble();
          totalSalary.value = (info['totalSalary'] ?? 0).toDouble();
        }
      } else {
        errorMessage.value = 'Failed to load salary data';
        print("⚠️ API Error: ${response.body}");
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print("❌ Exception in fetchSalaryForSelectedMonth: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/users/get-user-payroll'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final user = jsonDecode(response.body)['user'];
        hourlyRate.value = (user['hourlyRate'] ?? 0).toDouble();
        monthlyRate.value = (user['monthlySalary'] ?? 0).toDouble();
      } else {
        debugPrint("Failed to fetch user rates: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching user rates: $e");
    }
  }

  RxList<Map<String, dynamic>> totalWorkHourList = <Map<String, dynamic>>[].obs;

  Future<void> fetchTotalWorkHours(
      {required DateTime startDate,
      required DateTime endDate,
      String? userId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final from =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      final to =
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      String url =
          'http://localhost:3000/api/payroll/total-work-hours?startDate=$from&endDate=$to';
      if (userId != null) {
        url += '&userId=$userId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> data = json['data'];
        totalWorkHourList.assignAll(data.cast<Map<String, dynamic>>());
      } else {
        errorMessage.value = 'Failed to load total work hours.';
        print("⚠️ Response error: ${response.body}");
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print("❌ Exception fetching total work hours: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
