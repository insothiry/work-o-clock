import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:work_o_clock/src/screens/notifications/notification_screen.dart';

class DashboardController extends GetxController {
  // Observables
  var totalEmployees = 0.obs;
  var totalDepartments = 0.obs;
  var isLoading = false.obs;
  var isLoadingOT = false.obs;

  var pendingRequests = <Map<String, dynamic>>[].obs;
  var pendingRequestsOT = <Map<String, dynamic>>[].obs;
  var approvedOTRequests = <Map<String, dynamic>>[].obs;
  var approvedLeaveRequests = <Map<String, dynamic>>[].obs;
  var allRequests = <Map<String, dynamic>>[].obs;
  var allOTRequests = <Map<String, dynamic>>[].obs;

  final SocketService socketService = SocketService();

  @override
  void onInit() {
    super.onInit();
    initializeSocketConnection();
    fetchDashboardData();
    fetchAllRequests();
    fetchAllOTRequests();
  }

  // Initialize WebSocket connection
  void initializeSocketConnection() async {
    final String? token = await _getToken();
    if (token != null) {
      socketService.connectSocket(token);
    } else {
      debugPrint("Token not found");
    }
  }

  // Fetch and update dashboard data
  Future<void> fetchDashboardData() async {
    final String? token = await _getToken();
    if (token == null) return;

    try {
      final headers = _getAuthHeaders(token);

      // Fetch total employees
      final userResponse = await _fetchData(
        'http://localhost:3000/api/users/get-users',
        headers,
      );
      totalEmployees.value = userResponse?['totalUsers'] ?? 0;

      // Fetch total departments
      final departmentResponse = await _fetchData(
        'http://localhost:3000/api/companies/get-departments',
        headers,
      );
      totalDepartments.value = departmentResponse?['totalDepartments'] ?? 0;
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    }
  }

  // Fetch all leave requests
  Future<void> fetchAllRequests() async {
    final String? token = await _getToken();
    if (token == null) return;

    try {
      final headers = _getAuthHeaders(token);
      final response = await _fetchData(
        'http://localhost:3000/api/leaves/get-all-leave-requests',
        headers,
      );
      allRequests.value =
          List<Map<String, dynamic>>.from(response?['data'] ?? []);

      _filterRequests();
    } catch (e) {
      debugPrint('Error fetching leave requests: $e');
    }
  }

  // Fetch all overtime requests
  Future<void> fetchAllOTRequests() async {
    final String? token = await _getToken();
    if (token == null) return;

    try {
      final headers = _getAuthHeaders(token);
      final response = await _fetchData(
        'http://localhost:3000/api/overtimes/get-all-overtime-requests',
        headers,
      );
      allOTRequests.value =
          List<Map<String, dynamic>>.from(response?['data'] ?? []);

      _filterOTRequests();
    } catch (e) {
      debugPrint('Error fetching OT requests: $e');
    }
  }

  // Accept a leave request
  Future<void> acceptLeaveRequest(String leaveId) async {
    await _acceptRequest(
      'http://localhost:3000/api/leaves/accept-leave/$leaveId',
      isLoading,
      fetchAllRequests,
      "Leave approved",
    );
  }

  // Accept an overtime request
  Future<void> acceptOTRequest(String overtimeId) async {
    await _acceptRequest(
      'http://localhost:3000/api/overtimes/accept-overtime/$overtimeId',
      isLoadingOT,
      fetchAllOTRequests,
      "Overtime approved",
    );
  }

  // Helper function to filter leave and OT requests
  void _filterRequests() {
    approvedLeaveRequests.value = allRequests
        .where((request) => request['status'] == 'approved')
        .toList();
    pendingRequests.value =
        allRequests.where((request) => request['status'] == 'pending').toList();
  }

  void _filterOTRequests() {
    approvedOTRequests.value = allOTRequests
        .where((request) => request['status'] == 'approved')
        .toList();
    pendingRequestsOT.value = allOTRequests
        .where((request) => request['status'] == 'pending')
        .toList();
  }

  // Helper function to accept a request
  Future<void> _acceptRequest(
    String url,
    RxBool loadingFlag,
    Future<void> Function() refreshFunction,
    String successMessage,
  ) async {
    loadingFlag.value = true;
    final String? token = await _getToken();
    if (token == null) return;

    try {
      final headers = _getAuthHeaders(token);
      final response = await http.post(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        await refreshFunction();
        Get.snackbar("Success", successMessage,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      loadingFlag.value = false;
    }
  }

  // Helper function to get the auth token
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Helper function to create auth headers
  Map<String, String> _getAuthHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Helper function to fetch data
  Future<Map<String, dynamic>?> _fetchData(
      String url, Map<String, String> headers) async {
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      debugPrint('Error fetching data from $url: ${response.statusCode}');
      return null;
    }
  }

  // Helper function to format date
  String formatDate(String isoDate) {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
  }
}
