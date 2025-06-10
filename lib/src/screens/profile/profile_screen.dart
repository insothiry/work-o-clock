import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_o_clock/src/controller/profile_controller.dart';
import 'package:work_o_clock/src/screens/profile/change_password_screen.dart';
import 'package:work_o_clock/src/screens/profile/edit_profile_screen.dart';
import 'package:work_o_clock/src/widgets/base_confirm_dialog.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.to(() => const EditProfileScreen()),
          ),
        ],
      ),
      body: Obx(() => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/images/profile-icon.png'),
                ),
                const SizedBox(height: 16),
                Text(profileController.name.value,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(profileController.job.value,
                    style: const TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 16),
                Text(profileController.email.value,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Text(profileController.phone.value,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 32),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.key),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                  onTap: () => Get.to(() => const ChangePasswordScreen()),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: profileController.isDarkMode.value,
                    onChanged: (value) => profileController.toggleDarkMode(),
                  ),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('App Version'),
                  trailing: Text('v1.0.0'),
                ),
                const Divider(),
                ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                    onTap: () {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;

                      Get.dialog(
                        AlertDialog(
                          backgroundColor:
                              isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          title: Text(
                            'Privacy Policy',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          content: Text(
                            'We respect your privacy. Your data is securely stored and used only for attendance purposes.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
                                ),
                          ),
                          actions: [
                            TextButton(
                              child: Text(
                                'Close',
                                style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black),
                              ),
                              onPressed: () => Get.back(),
                            ),
                          ],
                        ),
                      );
                    }),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title:
                      const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () => _showLogoutConfirmationDialog(context),
                ),
              ],
            ),
          )),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showBaseDialog(
      title: "Confirm Logout",
      description: "Are you sure you want to logout?",
      onConfirm: () {
        profileController.logout();
        Get.back();
      },
    );
  }
}
