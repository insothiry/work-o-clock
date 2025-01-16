// ignore_for_file: avoid_print

import 'dart:async';
import 'package:get/get.dart';

class HomeController extends GetxController {
  Timer? _timer;
  var elapsedTime = Duration.zero.obs;
  var isClockedIn = false.obs;
  var clockInCount = 0.obs;
  var clockOutCount = 0.obs;
  var lastClockInTime = Rxn<DateTime>();
  var lastClockOutTime = Rxn<DateTime>();

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
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

  // Function to toggle clock-in/clock-out
  void toggleClockInOut() {
    final currentTime = DateTime.now();

    if (!isClockedIn.value) {
      // Clock in
      if (clockInCount.value < 2) {
        isClockedIn.value = true;
        startTimer();
        clockInCount.value++;
        lastClockInTime.value = currentTime;
        print(
            "Clocked in at $currentTime. Total clock-ins: ${clockInCount.value}");
      } else {
        print("You have already clocked in 2 times today.");
      }
    } else {
      // Clock out
      if (clockOutCount.value < 2) {
        isClockedIn.value = false;
        stopTimer();
        clockOutCount.value++;
        lastClockOutTime.value = currentTime;
        print(
            "Clocked out at $currentTime. Total clock-outs: ${clockOutCount.value}");
      } else {
        print("You have already clocked out 2 times today.");
      }
    }
  }

  // Helper function to display elapsed time as string (hours and minutes only)
  String get elapsedTimeString {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(elapsedTime.value.inHours);
    final minutes = twoDigits(elapsedTime.value.inMinutes.remainder(60));
    return "$hours:$minutes";
  }
}
