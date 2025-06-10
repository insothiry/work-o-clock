import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:work_o_clock/src/controller/theme_controller.dart';
import 'package:work_o_clock/src/screens/login/login_screen.dart';

class ProfileController extends GetxController {
  final ThemeController themeController = Get.put(ThemeController());

  var name = "".obs;
  var role = "".obs;
  var email = "".obs;
  var phone = "".obs;
  var job = "".obs;
  var isDarkMode = false.obs;
  var selectedLanguage = "English".obs;
  var activeAccountType = "Admin".obs;
  var accounts = ["Admin", "Employee"].obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = Get.isDarkMode;
    loadProfileDetails();
  }

  void toggleDarkMode() {
    themeController.toggleDarkMode();
    isDarkMode.value = !isDarkMode.value;
  }

  Future<void> loadProfileDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name.value = prefs.getString('userName') ?? 'Unknown User';
    role.value = prefs.getString('role') ?? 'Unknown Role';
    email.value = prefs.getString('email') ?? 'unknown@example.com';
    phone.value = prefs.getString('phone') ?? '';
    job.value = prefs.getString('job') ?? 'No Job Title';
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      Get.snackbar("Logout Failed", "No active session found",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Get.back();

      if (response.statusCode == 200) {
        await prefs.remove('token');
        Get.offAll(() => const LoginScreen());
      } else {
        Get.snackbar("Logout Failed", "Error logging out",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Failed to logout: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void switchAccount(String newAccount) {
    activeAccountType.value = newAccount;
    Get.snackbar("Switched Account", "Now using $newAccount account",
        snackPosition: SnackPosition.BOTTOM);
  }
}
