import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:work_o_clock/src/models/leave_suggestion.dart';
import 'package:work_o_clock/src/services/socket_service.dart';
import 'package:work_o_clock/src/widgets/base_confirm_dialog.dart';

class HomeController extends GetxController {
  Timer? _timer;
  var elapsedTime = Duration.zero.obs;
  var isClockedIn = false.obs;
  var clockInCount = 0.obs;
  var clockOutCount = 0.obs;
  var radius = 0.0.obs;
  var firstClockInTime = Rxn<DateTime>();
  var firstClockOutTime = Rxn<DateTime>();
  var secondClockInTime = Rxn<DateTime>();
  var secondClockOutTime = Rxn<DateTime>();

  var leaveSuggestion = Rxn<LeaveSuggestion>();

// Define Rx variables for shift times
  var morningShiftStart = Rxn<DateTime>();
  var morningShiftEnd = Rxn<DateTime>();
  var afternoonShiftStart = Rxn<DateTime>();
  var afternoonShiftEnd = Rxn<DateTime>();

  Timer? borderAnimationTimer;
  var isAnimatingBorder = false.obs;
  var currentLocation = Rx<LatLng>(const LatLng(0, 0));
  var locationFetched = false.obs;
  var name = ''.obs;
  var userToken = ''.obs;

  TextEditingController reasonController = TextEditingController();

  final SocketService socketService = SocketService();

  @override
  void onInit() {
    super.onInit();
    _getUserData();
    getCompanyRadius();
    _getUserLocation();
    initializeSocketConnection();
  }

  Future<void> _getUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    name.value = pref.getString('userName') ?? 'N/A';
    userToken.value = pref.getString('token') ?? '';
    debugPrint("User token: ${userToken.value}");
  }

  void initializeSocketConnection() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final String? token = pref.getString('token');
    if (token != null) {
      socketService.initNotificationSocket(token);
    } else {
      debugPrint("Token not found");
    }
  }

  @override
  void onClose() {
    borderAnimationTimer?.cancel();
    _timer?.cancel();
    super.onClose();
  }

  var isProcessingClockIn = false.obs;

  Future<void> handleClockInOut() async {
    isProcessingClockIn.value = true;

    await Future.delayed(const Duration(milliseconds: 200));

    toggleClockInOut();

    await Future.delayed(const Duration(milliseconds: 300));

    isProcessingClockIn.value = false;
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied.');
        return;
      }
    }

    currentLocation.value = const LatLng(11.5681, 104.8921);
    locationFetched.value = true;
    debugPrint("Current location: ${currentLocation.value}");
  }

  Future<void> getCompanyRadius() async {
    const String url = "http://localhost:3000/api/companies/get-company-radius";
    SharedPreferences pref = await SharedPreferences.getInstance();
    final String? token = pref.getString('token');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["radius"] != null) {
          // Convert the radius to a double (if it's an int)
          radius.value = (responseData["radius"] is int)
              ? (responseData["radius"] as int).toDouble()
              : responseData["radius"].toDouble();
          debugPrint("Company radius updated: ${radius.value} meters");
        } else {
          debugPrint("Radius not found in response.");
        }
      } else {
        debugPrint(
            "Failed to fetch company radius: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching company radius: $e");
    }
  }

  void updateLocation(LatLng newLocation) {
    currentLocation.value = newLocation;
    locationFetched.value = true;
  }

  Future<bool> _clockInRequest(double latitude, double longitude) async {
    const String url = "http://localhost:3000/api/attendances/clock-in";
    SharedPreferences pref = await SharedPreferences.getInstance();
    final String? token = pref.getString('token');

    try {
      // 🔹 First, check if the user is already clocked in
      final statusResponse = await http.get(
        Uri.parse("http://localhost:3000/api/attendances/status"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (statusResponse.statusCode == 200) {
        final statusData = jsonDecode(statusResponse.body);
        if (statusData['isClockedIn'] == true) {
          _showSnackBar("You must clock out before clocking in again.");
          return false;
        }
      }

      // 🔹 Proceed with clock-in if the user is NOT already clocked in
      final body = jsonEncode({"latitude": latitude, "longitude": longitude});
      debugPrint("Request Body: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showDialog(
            "Clock-in successful!", "You have successfully clocked in.");
        debugPrint("Response: ${response.body}");
        return true;
      } else if (responseData['message']?.contains(
              'You are clocking in late. Please provide a reason.') ==
          true) {
        _showReasonDialog();
      } else if (responseData['message']
              ?.contains('You have already clocked in for this shift today.') ==
          true) {
        _showShiftDialog();
      } else if (responseData['message']
              ?.contains('Clock-in is not allowed outside working hours.') ==
          true) {
        _showOutsideWorkHoursDialog();
      } else {
        _showSnackBar("Failed to clock in. Please try again.");
        debugPrint("Error: ${response.statusCode}, ${response.body}");
      }

      return false;
    } catch (e) {
      _showSnackBar("An error occurred: $e");
      debugPrint("Exception: $e");
      return false;
    }
  }

  Future<bool> _clockOutRequest(double latitude, double longitude) async {
    const String url = "http://localhost:3000/api/attendances/clock-out";
    SharedPreferences pref = await SharedPreferences.getInstance();
    final String? token = pref.getString('token');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showDialog(
            "Clock-out successful!", "You have successfully clocked out.");
        debugPrint("Response: ${response.body}");
        return true;
      } else if (responseData['message']?.contains(
              'You are clocking out early. Please provide a reason.') ==
          true) {
        _showReasonDialogForClockOut(latitude, longitude);
      } else {
        _showSnackBar("Failed to clock out. Please try again.");
        debugPrint("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e");
      debugPrint("Exception: $e");
    }
    return false;
  }

  void _showDialog(String title, String message) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      textConfirm: "OK",
      onConfirm: () {
        Get.back();
      },
    );
  }

  void _showSnackBar(String message) {
    Get.snackbar("Notice", message, snackPosition: SnackPosition.BOTTOM);
    debugPrint("Snackbar displayed with message: $message");
  }

  Future<bool> _clockInRequestWithReason(
      double latitude, double longitude, String reason) async {
    const String url = "http://localhost:3000/api/attendances/clock-in";
    SharedPreferences pref = await SharedPreferences.getInstance();
    final String? token = pref.getString('token');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(
            {"latitude": latitude, "longitude": longitude, "reason": reason}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar("Clock-in successful!");
        debugPrint("Response: ${response.body}");
        return true;
      } else {
        _showSnackBar("Failed to clock in. Please try again.");
        debugPrint("Error: ${response.statusCode}, ${response.body}");
        return false;
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e");
      debugPrint("Exception: $e");
      return false;
    }
  }

  void startTimer() {
    elapsedTime.value = Duration.zero;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedTime.value += const Duration(seconds: 1);
    });
  }

  void stopTimer() {
    _timer?.cancel();
    elapsedTime.value = Duration.zero;
  }

  Future<void> toggleClockInOut() async {
    final currentTime = DateTime.now();
    debugPrint("Toggle Clock-in/out Triggered at: $currentTime");

    if (!isClockedIn.value) {
      debugPrint("Attempting to Clock-In...");

      if (clockInCount.value < 2) {
        if (clockOutCount.value > 0 || clockInCount.value == 0) {
          if (clockInCount.value == 0 && firstClockInTime.value == null) {
            await _requestClockInWithValidation(currentTime, firstClockInTime);
          } else if (clockInCount.value == 1 &&
              secondClockInTime.value == null) {
            await _requestClockInWithValidation(currentTime, secondClockInTime);
          } else {
            _showSnackBar("Clock-in sequence error. Check previous clock-ins.");
          }
        } else {
          _showSnackBar("You cannot clock in again without clocking out.");
        }
      } else {
        _showSnackBar("You have already clocked in 2 times today.");
      }
    } else {
      debugPrint("Attempting to Clock-Out...");

      if (clockOutCount.value < 2) {
        final success = await _clockOutRequest(
          currentLocation.value.latitude,
          currentLocation.value.longitude,
        );

        if (success) {
          isClockedIn.value = false;
          isAnimatingBorder.value = false;
          borderAnimationTimer?.cancel();

          stopTimer();
          if (clockOutCount.value == 0 && firstClockOutTime.value == null) {
            firstClockOutTime.value = DateTime.now();
          } else if (clockOutCount.value == 1 &&
              secondClockOutTime.value == null) {
            secondClockOutTime.value = DateTime.now();
          }
          clockOutCount.value++;
        }
      } else {
        _showSnackBar("You have already clocked out 2 times today.");
      }
    }
  }

  Future<void> _requestClockInWithValidation(
      DateTime currentTime, Rxn<DateTime> clockInTimeSlot) async {
    bool success = await _clockInRequest(
        currentLocation.value.latitude, currentLocation.value.longitude);

    if (success) {
      debugPrint("Clock-in time set: $currentTime");
      clockInTimeSlot.value = currentTime;
      isClockedIn.value = true;
      startTimer();
      clockInCount.value++;
    } else {
      debugPrint("Clock-in request failed.");
    }
  }

  void _showReasonDialog() {
    TextEditingController reasonController = TextEditingController();

    showBaseDialog(
      title: "Clock-in Late",
      description: "Please provide a reason for clocking in late.",
      showReasonField: true,
      reasonController: reasonController,
      onConfirm: () async {
        final reason = reasonController.text.trim();
        if (reason.isNotEmpty) {
          bool success = await _clockInRequestWithReason(
            currentLocation.value.latitude,
            currentLocation.value.longitude,
            reason,
          );

          if (success) {
            isClockedIn.value = true;
            if (clockInCount.value == 0) {
              firstClockInTime.value = DateTime.now();
            } else if (clockInCount.value == 1) {
              secondClockInTime.value = DateTime.now();
            }
            startTimer();
            clockInCount.value++;
          }
          Get.back();
        } else {
          _showSnackBar("Reason is required.");
        }
      },
      onCancel: () {
        Get.back();
        debugPrint("Late clock-in canceled.");
      },
    );
  }

  void _showReasonDialogForClockOut(double latitude, double longitude) {
    TextEditingController reasonController = TextEditingController();

    showBaseDialog(
      title: "Early Clock-Out",
      description: "You're clocking out early. Please provide a reason.",
      showReasonField: true,
      reasonController: reasonController,
      onConfirm: () async {
        final reason = reasonController.text.trim();
        if (reason.isNotEmpty) {
          bool success =
              await _clockOutRequestWithReason(latitude, longitude, reason);
          if (success) {
            isClockedIn.value = false;
            isAnimatingBorder.value = false;
            borderAnimationTimer?.cancel();
            stopTimer();

            if (clockOutCount.value == 0 && firstClockOutTime.value == null) {
              firstClockOutTime.value = DateTime.now();
            } else if (clockOutCount.value == 1 &&
                secondClockOutTime.value == null) {
              secondClockOutTime.value = DateTime.now();
            }
            clockOutCount.value++;
          }

          Get.back();
        } else {
          _showSnackBar("Reason is required.");
        }
      },
      onCancel: () {
        Get.back();
        debugPrint("Early clock-out canceled.");
      },
    );
  }

  Future<bool> _clockOutRequestWithReason(
      double latitude, double longitude, String reason) async {
    const String url = "http://localhost:3000/api/attendances/clock-out";
    SharedPreferences pref = await SharedPreferences.getInstance();
    final String? token = pref.getString('token');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
          "reason": reason,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar("Clock-out successful!");
        debugPrint("Response: ${response.body}");
        return true;
      } else {
        _showSnackBar("Failed to clock out. Please try again.");
        debugPrint("Error: ${response.statusCode}, ${response.body}");
        return false;
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e");
      debugPrint("Exception: $e");
      return false;
    }
  }

  void _showShiftDialog() {
    showBaseDialog(
        title: "Shift Clocked In",
        description:
            "You have already clocked in for this shift today. Clock in again in the next shift.",
        showReasonField: false,
        showCancelButton: false,
        onConfirm: () {
          Get.back();
        });
  }

  void _showOutsideWorkHoursDialog() {
    showBaseDialog(
        title: "Shift Clocked In",
        description:
            "Clock-in is not allowed outside working hours. Clock in again in working hours.",
        showReasonField: false,
        showCancelButton: false,
        onConfirm: () {
          Get.back();
        });
  }

  String get elapsedTimeString {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(elapsedTime.value.inHours);
    final minutes = twoDigits(elapsedTime.value.inMinutes.remainder(60));
    final seconds = twoDigits(elapsedTime.value.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Future<void> fetchSmartLeaveSuggestion() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    userToken.value = pref.getString('token') ?? '';
    final token = userToken.value.trim();
    if (token.isEmpty) {
      debugPrint("⚠️ Token is empty. Cannot fetch leave suggestion.");
      return;
    }

    const String url = "http://localhost:3000/api/leaves/suggest-leave";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        leaveSuggestion.value = LeaveSuggestion.fromJson(data);
        debugPrint(
            "✅ Leave suggestion loaded: ${leaveSuggestion.value?.suggestion}");
      } else {
        debugPrint(
            "❌ Failed to fetch suggestion: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("🔥 Exception fetching leave suggestion: $e");
    }
  }
}
