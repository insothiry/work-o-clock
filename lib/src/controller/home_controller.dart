import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:work_o_clock/src/screens/notifications/notification_screen.dart';

class HomeController extends GetxController {
  Timer? _timer;
  var elapsedTime = Duration.zero.obs;
  var isClockedIn = false.obs;
  var clockInCount = 0.obs;
  var clockOutCount = 0.obs;
  var radius = 50.0.obs;
  var firstClockInTime = Rxn<DateTime>();
  var firstClockOutTime = Rxn<DateTime>();
  var secondClockInTime = Rxn<DateTime>();
  var secondClockOutTime = Rxn<DateTime>();

  Timer? borderAnimationTimer;
  var isAnimatingBorder = false.obs;
  var currentLocation = Rx<LatLng>(LatLng(0, 0));
  var locationFetched = false.obs;
  var name = ''.obs;
  var userToken = ''.obs;

  final SocketService socketService = SocketService();

  @override
  void onInit() {
    super.onInit();
    _getUserData();
    _startBorderAnimation();
    _getUserLocation();
    initializeSocketConnection();
  }

  void startBorderAnimation() {
    isAnimatingBorder.value = true;
    borderAnimationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Your animation logic
    });
  }

  void stopBorderAnimation() {
    borderAnimationTimer?.cancel();
    isAnimatingBorder.value = false;
  }

  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name.value = prefs.getString('userName') ?? 'N/A';
    userToken.value = prefs.getString('token') ?? '';
    debugPrint("User token: ${userToken.value}");
  }

  void initializeSocketConnection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token != null) {
      socketService.connectSocket(token);
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

    currentLocation.value =
        LatLng(11.5681, 104.8921); // Using the correct variable here
    locationFetched.value = true;
    debugPrint("Current location: ${currentLocation.value}");
  }

  void _startBorderAnimation() {
    borderAnimationTimer =
        Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (isClockedIn.value) {
        isAnimatingBorder.value = !isAnimatingBorder.value;
      } else {
        borderAnimationTimer?.cancel();
      }
    });
  }

  void updateLocation(LatLng newLocation) {
    currentLocation.value = newLocation;
    locationFetched.value = true; // Mark location as fetched
  }

  Future<void> _clockInRequest(double latitude, double longitude) async {
    const String url = "http://localhost:3000/api/attendances/clock-in";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"latitude": latitude, "longitude": longitude}),
      );

      if (response.statusCode == 201) {
        _showSnackBar("Clock-in successful!");
        debugPrint("Response: ${response.body}");
      } else {
        _showSnackBar("Failed to clock in. Please try again.");
        debugPrint("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e");
      debugPrint("Exception: $e");
    }
  }

  Future<void> _clockOutRequest(double latitude, double longitude) async {
    const String url = "http://localhost:3000/api/attendances/clock-out";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"latitude": latitude, "longitude": longitude}),
      );

      if (response.statusCode == 201) {
        _showSnackBar("Clock-out successful!");
        debugPrint("Response: ${response.body}");
      } else {
        _showSnackBar("Failed to clock out. Please try again.");
        debugPrint("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e");
      debugPrint("Exception: $e");
    }
  }

  void startTimer() {
    elapsedTime.value = Duration.zero;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      elapsedTime.value += const Duration(minutes: 1);
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void toggleClockInOut() {
    final currentTime = DateTime.now();

    if (!isClockedIn.value) {
      if (clockInCount.value < 2) {
        if (clockOutCount.value > 0 || clockInCount.value == 0) {
          isClockedIn.value = true;
          startTimer();
          clockInCount.value++;

          if (clockInCount.value == 1) {
            firstClockInTime.value = currentTime;
          } else if (clockInCount.value == 2) {
            secondClockInTime.value = currentTime;
          }

          _clockInRequest(
              currentLocation.value.latitude, currentLocation.value.longitude);
        } else {
          _showSnackBar("You cannot clock in again without clocking out.");
        }
      } else {
        _showSnackBar("You have already clocked in 2 times today.");
      }
    } else {
      if (clockOutCount.value < 2) {
        isClockedIn.value = false;
        stopTimer();
        clockOutCount.value++;

        if (clockOutCount.value == 1) {
          firstClockOutTime.value = currentTime;
        } else if (clockOutCount.value == 2) {
          secondClockOutTime.value = currentTime;
        }

        _clockOutRequest(
            currentLocation.value.latitude, currentLocation.value.longitude);
      } else {
        _showSnackBar("You have already clocked out 2 times today.");
      }
    }
  }

  String get elapsedTimeString {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(elapsedTime.value.inHours);
    final minutes = twoDigits(elapsedTime.value.inMinutes.remainder(60));
    return "$hours:$minutes";
  }

  void _showSnackBar(String message) {
    Get.snackbar("Notice", message, snackPosition: SnackPosition.BOTTOM);
    debugPrint("Snackbar displayed with message: $message");
  }
}
